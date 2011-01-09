-- Twitterの認証情報 (Twitterでのログイン時にアップデートされる)
CREATE TABLE IF NOT EXISTS twitter_user_auth (
    twitter_user_id INT UNSIGNED PRIMARY KEY,
    user_id INT UNSIGNED UNIQUE NOT NULL,
    access_token VARCHAR(255) UNIQUE NOT NULL DEFAULT '',
    access_token_secret VARCHAR(255) NOT NULL DEFAULT '',
    created_at DATETIME NOT NULL
) ENGINE=InnoDB;

-- Twitterのユーザ情報キャッシュ
CREATE TABLE IF NOT EXISTS twitter_user_cache (
    twitter_user_id INT UNSIGNED PRIMARY KEY,
    screen_name VARCHAR(255) NOT NULL,
    profile_image_url TEXT,
    updated_at DATETIME NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- アイテム
CREATE TABLE IF NOT EXISTS items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    item_from ENUM('amazon') NOT NULL DEFAULT 'amazon',
    item_code VARCHAR(255) NOT NULL COMMENT 'AmazonならばASIN',
    UNIQUE INDEX ( item_from, item_code )
) ENGINE=InnoDB;

-- Amazonから得たアイテム情報のキャッシュ
CREATE TABLE IF NOT EXISTS amazon_item_cache (
    ASIN VARCHAR(10) PRIMARY KEY,
    item_yaml TEXT NOT NULL DEFAULT '',
    updated_at DATETIME NOT NULL
) ENGINE=InnoDB;

-- アイテムの所有情報
CREATE TABLE IF NOT EXISTS user_items (
    user_id INT UNSIGNED NOT NULL,
    item_id INT UNSIGNED NOT NULL,
    status ENUM ('unread','reading','done') NOT NULL DEFAULT 'unread',
    status_history_yaml TEXT COMMENT 'YAML形式のステータス変更履歴',
    status_history_version UNSIGNED INT NOT NULL DEFAULT 1,
    UNIQUE INDEX ( user_id, item_id )
) ENGINE=InnoDB;


