CHANGE MASTER TO 
    MASTER_HOST = '&ADDRESS',
    MASTER_PORT = 3306,
    MASTER_USER = 'slave_user',
    MASTER_PASSWORD = 'FTCFeIM1YTQPPy-Ow-',
    MASTER_AUTO_POSITION = 1;

START SLAVE;

SET @@global.read_only = ON;