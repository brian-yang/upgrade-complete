final int SCREEN_WIDTH = 1024;
final int SCREEN_HEIGHT = 768;

int numEnemies = 3;
int level = 1;

class Game {
  // PImage player;
  Player player;
  ArrayList<Enemy> enemies;
  ArrayList<Enemy> activeEnemies;
  ArrayList<Enemy> removedEnemies;
  ArrayList<Enemy> passEnemies;
  int timer;
  int enemyTimer;
  Shooter shooter;
  Lightning lightning;
  // ======================================================
  /* SETUP GAME */
  // ======================================================


  Game() {
    
    numEnemies += (level / 2);
    
    // Player
    player = new Player(width / 2, height - 100);
    // Enemies
    enemies = new ArrayList<Enemy>();
    activeEnemies = new ArrayList<Enemy>();
    removedEnemies = new ArrayList<Enemy>();
    passEnemies = new ArrayList<Enemy>();
    shooter = new Shooter(100);
    lightning = new Lightning(player.getX(), player.getY());
    for (int i = 0; i < numEnemies; i++) {
      enemies.add(new Enemy((int) (Math.random()* (width-100)), 0, level));
    }
    // Timer
    timer = 0;
  }
  // ======================================================
  /* RUN GAME */
  // ======================================================

  void run() {
    gameBackground();
    drawPlayer();
    playerFlex();
    drawEnemies();
    shooter.show();
    shooter.update();
    lightning();
    destroyEnemies();
    passingEnemies();
    //println("Player angle: " + player.getAngle());
    /*  We created our own timer
     *  because the built-in timing functions
     *  were buggy.
     */
    timer++;
  }

  // ======================================================
  /* WINNING CONDITION */
  // ======================================================

  boolean isFinished() {
    return (removedEnemies.size() + passEnemies.size() == numEnemies);
  }

  // ======================================================
  /* DRAW HELPER METHODS */
  // ======================================================

  void drawPlayer() {
    showPlayer();
  }

  void drawEnemies() {
    enemyTimer = timer / 100;
    //System.out.println(enemyTimer); // test timer

    if (enemyTimer < numEnemies &&
      !activeEnemies.contains(enemies.get(enemyTimer)) &&
      !removedEnemies.contains(enemies.get(enemyTimer)) &&
      !passEnemies.contains(enemies.get(enemyTimer))) {
      activeEnemies.add(enemies.get(enemyTimer));
    }

    for (Enemy enemy : activeEnemies) {
      showEnemy(enemy, enemy.getX(), enemy.getY());
    }

    for (Enemy enemy : activeEnemies) {
      enemy.setY(enemy.getY() + 1);
      //System.out.println(enemy.getY()); // test y coordinate of current enemy
    }
    //System.out.println(activeEnemies); // test how many enemies are being created
  }

  void destroyEnemies() {
    boolean removed = false;
    for (int i = 0; i < activeEnemies.size(); i++) {
      removed = shootDestroy(activeEnemies.get(i));
      if (!removed) {
        removed = laserDestroy(activeEnemies.get(i));
      }
      if (removed) {
        removedEnemies.add(activeEnemies.remove(i));
        i--;
        removed = false;
      }
    }
  }

  
  void passingEnemies() {
    for (int i = 0; i < activeEnemies.size(); i++) {
      if (activeEnemies.get(i).getY() >= SCREEN_HEIGHT) {
        println("passed");
        passEnemies.add(activeEnemies.get(i));
        activeEnemies.remove(activeEnemies.get(i));
      }
    }
  }
  // ======================================================
  /* WEAPONS */
  // ======================================================
  
  // Shooter
  void shoot() {
    shooter.shoot(player.getX(), player.getY(), player.getAngle());
  }

  boolean shootDestroy(Enemy enemy) {
    //println(shooter.bullets.size());
    for (int j = 0; j < shooter.bullets.size(); j++) {
      if (enemy.hasCollided(shooter.bullets.get(j).getX(), shooter.bullets.get(j).getY())&&enemy.health <= 1){
        shooter.bullets.remove(j);
        return true;}
      else {if (enemy.hasCollided(shooter.bullets.get(j).getX(), shooter.bullets.get(j).getY())){
        enemy.health -= 1;
        shooter.bullets.remove(j);
      }
      }   
    }
    return false;
  }

  // Laser
  void laser() {
    // Laser
    pushStyle();
    stroke(255, 0, 0);
    strokeWeight(5);
    line(player.getX(), player.getY(), mouseX, mouseY);
    popStyle();
  }

  boolean laserDestroy(Enemy enemy) {
    return enemy.laserShot();
  }

  // Lightning
  void lightning() {
    if (activeEnemies.size() > 0) {
      Enemy e = closestEnemy();
      flashLightning(e);
      e.health -= 0.005;
      println(e.health);
      if (e.health <= 0) {
        activeEnemies.remove(e);
        removedEnemies.add(e);
      }
      lightning.reset(player.getX(), player.getY());
    }
  }

  Enemy closestEnemy() {
    Enemy closest = activeEnemies.get(0);
    float distance = -1;
    for (Enemy e : activeEnemies) {
      float enemyDistance = dist(e.getX(), e.getY(), player.getX(), player.getY());
      if (enemyDistance < distance || distance == -1) {
        distance = enemyDistance;
        closest = e;
      }
    }
    return closest;
  }
  
  float getLightningAngle(Enemy closest) {
    float angle = atan2(closest.getY() - player.getY(), closest.getX() - player.getX());
    angle += PI;
    if (angle < 0) {
      angle += TWO_PI;
    }
    return angle;
  }
  
  void flashLightning(Enemy e) {
    float x1, y1, x2, y2;
    if (e.getX() <= player.getX()) {
      x1 = e.getX() - e.getSpriteWidth() / 8;
      x2 = player.getX() + player.getSpriteWidth() / 8;
    } else {
      x1 = player.getX() - player.getSpriteWidth() / 8;
      x2 = e.getX() + e.getSpriteWidth() / 8;
    }
    if (e.getY() <= player.getY()) {
      y1 = e.getY() - e.getSpriteHeight() / 8;
      y2 = player.getY() + player.getSpriteHeight() / 8;
    } else {
      y1 = player.getY() - player.getSpriteHeight() / 8;
      y2 = e.getY() + e.spriteHeight / 8;
    }
    lightning.show(x1, y1, x2, y2, getLightningAngle(e));
  }
}