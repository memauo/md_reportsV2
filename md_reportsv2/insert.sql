CREATE TABLE md_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,

    owner VARCHAR(60) NOT NULL,
    admin VARCHAR(60) DEFAULT NULL,

    status ENUM('waiting', 'solving', 'closed') DEFAULT 'waiting',
    type ENUM('player', 'bug', 'other'),

    header VARCHAR(50) NOT NULL,
    info TEXT NOT NULL,

    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateclosed JSON DEFAULT NULL
);

CREATE TABLE md_reports_chat (
    id INT AUTO_INCREMENT PRIMARY KEY,

    report_id INT NOT NULL,
    sender VARCHAR(60) NOT NULL,
    message TEXT NOT NULL,

    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (report_id) REFERENCES md_reports(id) ON DELETE CASCADE
);