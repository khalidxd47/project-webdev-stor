<?php

/** طابور بريد دائم؛ AES-256-GCM؛ لا توضع الروابط أو كلمات المرور في السجلات. */
function encryptPayload(array $d): string
{
    $iv = random_bytes(12);
    $tag = '';
    $cipher = openssl_encrypt(json_encode($d, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR), 'aes-256-gcm', hex2bin(config()['encryption_key']), OPENSSL_RAW_DATA, $iv, $tag);

    return base64_encode($iv.$tag.$cipher);
}

function decryptPayload(string $s): array
{
    $raw = base64_decode($s, true);
    if (false === $raw || strlen($raw) < 28) {
        throw new RuntimeException('PAYLOAD_INVALID');
    }

    $plain = openssl_decrypt(substr($raw, 28), 'aes-256-gcm', hex2bin(config()['encryption_key']), OPENSSL_RAW_DATA, substr($raw, 0, 12), substr($raw, 12, 16));
    if (false === $plain) {
        throw new RuntimeException('PAYLOAD_KEY_MISMATCH');
    }

    return json_decode($plain, true, 512, JSON_THROW_ON_ERROR);
}

function queueMail(int $user, ?int $order, string $recipient, string $template, string $subject, array $payload, string $key): int
{
    query('INSERT INTO email_outbox(user_id,order_id,recipient,template,subject,payload_encrypted,deduplication_key) VALUES (?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)', [$user, $order, $recipient, $template, $subject, encryptPayload($payload), $key]);

    return (int) db()->lastInsertId();
}

function mailTemplate(string $name, array $data, array $raw = []): string
{
    $source = file_get_contents(__DIR__.'/mail-templates/'.$name.'.html');

    return preg_replace_callback('/{{(\w+)}}/', fn ($m) => in_array($m[1], $raw, true) ? (string) ($data[$m[1]] ?? '') : e($data[$m[1]] ?? ''), $source);
}

function renderInvoice(array $o): string
{
    $items = '';
    foreach ($o['items'] as $i) {
        $items .= mailTemplate('invoice-item', ['name' => $i['name'], 'size' => $i['size'], 'color' => $i['color'], 'quantity' => $i['qty'], 'price' => number_format($i['price'], 2), 'total' => number_format($i['price'] * $i['qty'], 2)]);
    }

    return mailTemplate('invoice', ['invoiceNumber' => $o['invoiceNumber'], 'orderNumber' => $o['number'], 'date' => $o['date'], 'name' => $o['customer']['name'], 'email' => $o['customer']['email'], 'address' => implode('، ', [$o['customer']['city'], $o['customer']['district'], $o['customer']['street']]), 'items' => $items, 'subtotal' => number_format($o['subtotal'], 2), 'shipping' => number_format($o['shipping'], 2), 'total' => number_format($o['total'], 2)], ['items']);
}

function sendNextMail(): array
{
    $smtp = config()['smtp'];
    if (empty($smtp['host'])) {
        return ['configured' => false, 'sent' => false];
    }

    $job = transaction(function () {
        $j = one("SELECT * FROM email_outbox WHERE (status='queued' AND available_at<=UTC_TIMESTAMP(3)) OR (status='processing' AND locked_at<DATE_SUB(UTC_TIMESTAMP(3),INTERVAL 5 MINUTE)) ORDER BY id LIMIT 1 FOR UPDATE SKIP LOCKED");
        if (!$j) {
            return null;
        }

        query("UPDATE email_outbox SET status='processing',locked_at=UTC_TIMESTAMP(3),attempts=attempts+1 WHERE id=?", [$j['id']]);
        ++$j['attempts'];

        return $j;
    }
    );
    if (!$job) {
        return ['configured' => true, 'sent' => false];
    }

    try {
        $payload = decryptPayload($job['payload_encrypted']);
        if ('password_reset' === $job['template'] && !one('SELECT id FROM password_reset_tokens WHERE id=? AND used_at IS NULL AND expires_at>UTC_TIMESTAMP(3)', [$payload['resetId']])) {
            query("UPDATE email_outbox SET status='cancelled',payload_encrypted=NULL,locked_at=NULL WHERE id=?", [$job['id']]);

            return ['configured' => true, 'sent' => false];
        }

        require_once ROOT.'/vendor/autoload.php';
        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
        $mail->isSMTP();
        $mail->Host = $smtp['host'];
        $mail->Port = (int) $smtp['port'];
        $mail->SMTPAuth = !empty($smtp['user']);
        $mail->Username = $smtp['user'];
        $mail->Password = $smtp['password'];
        $mail->SMTPSecure = $smtp['secure'] ? 'ssl' : 'tls';
        $mail->Timeout = 15;
        $mail->CharSet = 'UTF-8';
        $mail->setFrom($smtp['from_email'], $smtp['from_name']);
        $mail->addAddress($job['recipient']);
        $mail->Subject = $job['subject'];
        $mail->isHTML(true);
        $mail->MessageID = '<stor-mail-'.$job['id'].'@'.parse_url(config()['origin'], PHP_URL_HOST).'>';
        if ('invoice' === $job['template']) {
            $order = getOrder((int) $payload['orderId']);
            $html = renderInvoice($order);
            $mail->Body = $html;
            $mail->AltBody = 'فاتورة '.$order['invoiceNumber'];
            $mail->addStringAttachment($html, $order['invoiceNumber'].'.html', 'base64', 'text/html');
        } else {
            $mail->Body = mailTemplate('password_reset' === $job['template'] ? 'password-reset' : 'order-status', $payload);
            $mail->AltBody = $job['subject'].' '.($payload['link'] ?? '');
        }

        $mail->send();
        query("UPDATE email_outbox SET status='sent',sent_at=UTC_TIMESTAMP(3),locked_at=NULL,last_error=NULL,payload_encrypted=NULL WHERE id=?", [$job['id']]);

        return ['configured' => true, 'sent' => true];
    } catch (Throwable $error) {
        $failed = $job['attempts'] >= 5;
        $delay = min(3600, 30 * 2 ** $job['attempts']);
        query('UPDATE email_outbox SET status=?,locked_at=NULL,last_error=?,available_at=DATE_ADD(UTC_TIMESTAMP(3),INTERVAL ? SECOND) WHERE id=?', [$failed ? 'failed' : 'queued', 'SMTP_OR_TEMPLATE_ERROR', $delay, $job['id']]);

        return ['configured' => true, 'sent' => false, 'failed' => $failed];
    }
}
