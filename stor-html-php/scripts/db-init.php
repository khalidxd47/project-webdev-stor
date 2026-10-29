<?php

/** يطبق SQL مرة واحدة على قاعدة فارغة فقط، لا يمس قاعدة Node.js. */
if (PHP_SAPI !== 'cli') {
    exit;
}

require __DIR__.'/../app/bootstrap.php';
try {
    $count = (int) one('SELECT COUNT(*) AS n FROM information_schema.tables WHERE table_schema=DATABASE()')['n'];
    if ($count > 0) {
        if (one("SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='schema_migrations'")) {
            $migration = one('SELECT checksum FROM schema_migrations WHERE version=?', ['php-1']);
            $checksum = hash_file('sha256', ROOT.'/database/01-schema.sql').hash_file('sha256', ROOT.'/database/02-seed.sql');
            if ($migration && hash_equals($migration['checksum'], hash('sha256', $checksum))) {
                echo "Database already initialized; unchanged.\n";
                exit;
            }
        }
        throw new RuntimeException('Use a new empty database. Existing tables were not changed.');
    }

    foreach (['01-schema.sql', '02-seed.sql'] as $name) {
        $sql = file_get_contents(ROOT.'/database/'.$name);
        db()->exec($sql);
    }

    db()->exec('CREATE TABLE schema_migrations(version VARCHAR(50) PRIMARY KEY,checksum CHAR(64) NOT NULL,applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB');
    query('INSERT INTO schema_migrations(version,checksum) VALUES (?,?)', ['php-1', hash('sha256', hash_file('sha256', ROOT.'/database/01-schema.sql').hash_file('sha256', ROOT.'/database/02-seed.sql'))]);
    echo "PHP database initialized with 15 products. Create admin next.\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Database setup failed: '.$e->getMessage()."\n");
    exit(1);
}
