<?php

/** إضافة أدمن من الطرفية فقط؛ لا كلمة مرور افتراضية. */
if (PHP_SAPI !== 'cli') {
    exit;
}

require __DIR__.'/../app/bootstrap.php';
function ask(string $s): string
{
    echo $s;

    return trim(fgets(STDIN) ?: '');
}

try {
    $name = text(['name' => ask('Admin full name: ')], 'name', 3, 120);
    $email = emailInput(['email' => ask('Admin email: ')]);
    $username = strtolower(ask('Admin username: '));
    if (!preg_match('/^[a-z0-9_.-]{3,50}$/', $username)) {
        throw new RuntimeException('Invalid username.');
    }

    // محليًا فقط؛ نستخدم قارئًا يخفي الإدخال عندما تسمح الطرفية.
    function secret(string $prompt): string
    {
        echo $prompt;
        if (PHP_OS_FAMILY === 'Windows') {
            $command = 'powershell -NoProfile -Command "$p=Read-Host -AsSecureString; $b=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); try {[Runtime.InteropServices.Marshal]::PtrToStringBSTR($b)} finally {[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b)}"';
            $value = shell_exec($command);

            return rtrim((string) $value, "\r\n");
        }
        system('stty -echo');
        try {
            $value = rtrim(fgets(STDIN) ?: '', "\r\n");
        } finally {
            system('stty echo');
            echo "\n";
        }

        return $value;
    }

    $password = passwordInput(['password' => secret('Password (12+ characters, hidden): ')]);
    if ($password !== secret('Repeat password: ')) {
        throw new RuntimeException('Passwords do not match.');
    }

    insert('INSERT INTO users(role_id,full_name,email,username,password_hash) VALUES (2,?,?,?,?)', [$name, $email, $username, passwordHash($password)]);
    echo "Admin created. Open /dashboard.php.\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Admin creation failed: '.($e instanceof PDOException ? 'Email/username duplicate or database connection failed.' : $e->getMessage())."\n");
    exit(1);
}
