<?php

/** نفّذه دوريًا من cron أو Task Scheduler. عند غياب SMTP تبقى الرسائل في الطابور. */
if (PHP_SAPI !== 'cli') {
    exit;
}

require __DIR__.'/../app/bootstrap.php';
require ROOT.'/app/orders.php';
require ROOT.'/app/mail.php';
try {
    $sent = 0;
    for ($i = 0; $i < 10; ++$i) {
        $r = sendNextMail();
        if (empty($r['sent'])) {
            break;
        }
        ++$sent;
    }
    echo "Mail worker completed. Sent: $sent\n";
} catch (Throwable $e) {
    fwrite(STDERR, "Mail worker failed; check database and SMTP configuration.\n");
    exit(1);
}
