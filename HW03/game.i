# 1 "game.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "game.c"
# 1 "game.h" 1

typedef struct {
    int oldX;
    int oldY;
    int x;
    int y;
    unsigned short backgroundColor;
    unsigned short color;
    int ableToShoot;
    int velocity;
} Player;


typedef struct {
    int oldX;
    int oldY;
    int x;
    int y;
    int active;
    int erased;
} Enemy;


typedef struct {
    int x;
    int y;
    int oldX;
    int active;
    int velocity;
} Bullet;


void initializeGame();
void updateGame();
void drawGame();
void initializeEnemy(Enemy *enemyPtr);
void updateEnemy(Enemy* enemyPtr);
void drawEnemy(Enemy* enemyPtr);
void updatePlayer();
void drawPlayer();
void spawnEnemies();
void drawBackground();




int lives, timeSoundPlays, gameStarted;
int zoneX, zoneY, zoneSize, seed;


Player p;
Player *playerPtr;




extern Enemy enemies[50];

int numKilled, numPerSpawn, numOnBoard, maxOnBoard;



extern Bullet bullets[20];
# 2 "game.c" 2
# 1 "gba.h" 1




typedef signed char s8;
typedef unsigned char u8;
typedef signed short s16;
typedef unsigned short u16;
typedef signed int s32;
typedef unsigned int u32;
typedef signed long long s64;
typedef unsigned long long u64;






extern volatile unsigned short *videoBuffer;
# 36 "gba.h"
void waitForVBlank();


int collision(int x1, int y1, int width1, int height1, int x2, int y2, int width2, int height2);
# 56 "gba.h"
void drawRect(int x, int y, int width, int height, volatile unsigned short color);
void drawRectDMA(int x, int y, int width, int height, volatile unsigned short color);
void fillScreen(volatile unsigned short color);
void drawChar(int x, int y, char ch, unsigned short color);
void drawString(int x, int y, char *str, unsigned short color);
# 76 "gba.h"
extern unsigned short oldButtons;
extern unsigned short buttons;




typedef volatile struct {
    volatile const void *src;
    volatile void *dst;
    volatile unsigned int cnt;
} DMA;
extern DMA *dma;
# 108 "gba.h"
void DMANow(int channel, volatile const void *src, volatile void *dst, unsigned int cnt);
# 3 "game.c" 2
# 1 "sound.h" 1
# 75 "sound.h"
enum {
  REST = 0,
  NOTE_C2 =44,
  NOTE_CS2 =157,
  NOTE_D2 =263,
  NOTE_DS2 =363,
  NOTE_E2 =457,
  NOTE_F2 =547,
  NOTE_FS2 =631,
  NOTE_G2 =711,
  NOTE_GS2 =786,
  NOTE_A2 =856,
  NOTE_AS2 =923,
  NOTE_B2 =986,
  NOTE_C3 =1046,
  NOTE_CS3 =1102,
  NOTE_D3 =1155,
  NOTE_DS3 =1205,
  NOTE_E3 =1253,
  NOTE_F3 =1297,
  NOTE_FS3 =1339,
  NOTE_G3 =1379,
  NOTE_GS3 =1417,
  NOTE_A3 =1452,
  NOTE_AS3 =1486,
  NOTE_B3 =1517,
  NOTE_C4 =1547,
  NOTE_CS4 =1575,
  NOTE_D4 =1602,
  NOTE_DS4 =1627,
  NOTE_E4 =1650,
  NOTE_F4 =1673,
  NOTE_FS4 =1694,
  NOTE_G4 =1714,
  NOTE_GS4 =1732,
  NOTE_A4 =1750,
  NOTE_AS4 =1767,
  NOTE_B4 =1783,
  NOTE_C5 =1798,
  NOTE_CS5 =1812,
  NOTE_D5 =1825,
  NOTE_DS5 =1837,
  NOTE_E5 =1849,
  NOTE_F5 =1860,
  NOTE_FS5 =1871,
  NOTE_G5 =1881,
  NOTE_GS5 =1890,
  NOTE_A5 =1899,
  NOTE_AS5 =1907,
  NOTE_B5 =1915,
  NOTE_C6 =1923,
  NOTE_CS6 =1930,
  NOTE_D6 =1936,
  NOTE_DS6 =1943,
  NOTE_E6 =1949,
  NOTE_F6 =1954,
  NOTE_FS6 =1959,
  NOTE_G6 =1964,
  NOTE_GS6 =1969,
  NOTE_A6 =1974,
  NOTE_AS6 =1978,
  NOTE_B6 =1982,
  NOTE_C7 =1985,
  NOTE_CS7 =1989,
  NOTE_D7 =1992,
  NOTE_DS7 =1995,
  NOTE_E7 =1998,
  NOTE_F7 =2001,
  NOTE_FS7 =2004,
  NOTE_G7 =2006,
  NOTE_GS7 =2009,
  NOTE_A7 =2011,
  NOTE_AS7 =2013,
  NOTE_B7 =2015,
  NOTE_C8 =2017
} NOTES;
# 4 "game.c" 2


int zoneMoved;
int powerUpX, powerUpY, powerActivated;


void initializeGame(){

    zoneX = 50 + rand() % 100;
    zoneY = 40 + rand() % 100;
    zoneSize = 30;
    zoneMoved = 0;

    for(int i = 0; i < 20; i++){
        bullets[i].active = 0;
    }

    for(int i = 0; i < 50; i++){
        enemies[i].active = 0;
    }


    playerPtr = &p;
    p.oldX = 100;
    p.oldY = 65;
    p.x = 100;
    p.y = 65;
    p.backgroundColor = ((31&31) | (25&31) << 5 | (15&31) << 10);
    p.color = ((15&31) | (0&31) << 5 | (20&31) << 10);
    p.ableToShoot = 1;
    p.velocity = 1;

    powerActivated = 0;

    numPerSpawn = 2;
    numKilled = 0;
    maxOnBoard = 2;
    numOnBoard = 0;

    lives = 3;
    drawBackground();
}


void drawBackground(){
    drawRectDMA(40, 0, 160, 160, ((31&31) | (25&31) << 5 | (15&31) << 10));
    drawString(2, 2, "Lives:", ((31&31) | (31&31) << 5 | (31&31) << 10));
    drawRect(zoneX, zoneY, zoneSize, zoneSize, ((31&31) | (0&31) << 5 | (0&31) << 10));
}


void spawnEnemies() {
    int spawned = 0;
    if (numOnBoard < maxOnBoard){
        for(int i = 0; i < 8; i++){
            if(enemies[i].active == 0){
                initializeEnemy(&enemies[i]);
                numOnBoard++;
                spawned++;
                if(spawned == numPerSpawn){
                    break;
                }
            }
        }
    }
}


int skipFrame = 0;
int skipFrame2 = 0;


void updateGame(){
    seed++;
    srand(seed);
    updatePlayer();

    timeSoundPlays++;
    if (timeSoundPlays == 45){
        *(volatile u16*)0x0400006C = (1<<15);
        *(volatile u16*)0x04000068 = 0;
    }

    skipFrame++;
    if(skipFrame == 3){
        for (int i = 0; i < 50; i++){
            if(enemies[i].active){
                updateEnemy(&enemies[i]);
            }
        }
        skipFrame = 0;
    }

    skipFrame2++;
    if(skipFrame2 == 8){
        spawnEnemies();
        skipFrame2 = 0;
    }

    if (numKilled <= 2){
        maxOnBoard = 2;
    } else if(numKilled <= 12){
        maxOnBoard = 6;
    } else if (numKilled <= 20){
        if(!zoneMoved){
            drawRectDMA(zoneX, zoneY, zoneSize, zoneSize, ((31&31) | (25&31) << 5 | (15&31) << 10));
            zoneX = 50 + rand() % 100;
            zoneY = 10 + rand() % 100;
            zoneMoved = 1;
            zoneSize = 35;
            seed += playerPtr->x;
            srand(seed);
            powerUpX = 50 + rand() % 100;
            powerUpY = 10 + rand() % 100;
            powerActivated = 1;
        }
        maxOnBoard = 12;
    } else if (numKilled <= 40){
        if(zoneMoved == 1){
            drawRectDMA(zoneX, zoneY, zoneSize, zoneSize, ((31&31) | (25&31) << 5 | (15&31) << 10));
            zoneX = 50 + rand() % 100;
            zoneY = 10 + rand() % 100;
            zoneMoved = 2;
            zoneSize = 40;
        }
    }

    if (powerActivated && collision(playerPtr->x, playerPtr->y, 8, 8, powerUpX, powerUpY, 5, 5)){
        powerActivated = 0;
        playerPtr->velocity *= 2;
        drawRect(powerUpX, powerUpY, 5, 5, ((31&31) | (25&31) << 5 | (15&31) << 10));
    }
}


void drawGame(){
    drawRectDMA(zoneX, zoneY, zoneSize, zoneSize, ((31&31) | (0&31) << 5 | (0&31) << 10));
    drawPlayer();
    for (int i = 0; i < 50; i++){
        if(enemies[i].active){
            drawEnemy(&enemies[i]);
        }
    }
    for (int i = 0; i < lives; i++){
        drawRect(2 + (i * 12), 12, 10, 10, ((31&31) | (0&31) << 5 | (31&31) << 10));
    }
    if (powerActivated){
        drawRect(powerUpX, powerUpY, 5, 5, ((0&31) | (0&31) << 5 | (31&31) << 10));
    }
}
