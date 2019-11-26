class Rendered
{
  int x = 0;               //Position en x
  int y = 0;               //Position en y
  boolean isActive = true; //Boolean pour savoir si l'objet est considéré comme actif ou non
  String ID = "";          //String permettant de différencié les différents Rendered

  //Fonction appelé à chaque frame par le draw() dans Pacman
  void Update() {
  }

  //Accesseurs
  int getX() {
    return x;
  }
  
  int getY() {
    return y;
  }

  String getID()
  {
    return ID;
  }

  //Mutateur
  void setActive(boolean active)
  {
    isActive = active;
  }
}

class Player extends Rendered
{
  //Déclaration des variables
  //Variables concernants les caractéristiques du joueur
  String ID = "pacman";

  private int x = 0;                  //Position en x
  private int y = 0;                  //Position en y
  private int initx = 0;              //Postion initiale en x
  private int inity = 0;              //Position initiale en y
  private int lastx = 0;              //Dernière position en x
  private int lasty = 0;              //Dernière position en y
  private boolean isActive = true;    //Si l'objet est actif ou non (i.e. s'il est affiché ou non)
  private int skinStep = 0;           //Variable indicant l'image à afficher pour le joueur (Mouvement)
  private float secondSkinStep = 0;   //Variable permettant de modifier la vitesse les images du pacman change
  private int dskinStep = 0;          //Variable indicant l'image à afficher pour le joueur (Mort)
  private float dsecondSkinStep = 0;  //Variable permettant de modifier la vitesse les images du pacman change
  private int lskinStep = 0;          //Variable indicant l'image à afficher pour le joueur (Apparition)
  private float lsecondSkinStep = 0;  //Variable permettant de modifier la vitesse les images du pacman change
  private int pacmanSize = 12;        //Taille du pacman
  private int pacmanState = 0;        //Etat du pacman

  //Variables concernants les mouvements du joueur
  private boolean up = false, down = false, left = false, right = false;         //Pour la direction du joueur
  private boolean canUp = true, canDown = true, canLeft = true, canRight = true; //Pour la possibilité de mouvement
  private String Key = "";           //Touche du clavier utilisé
  private boolean isMoving = false;  //Boolean pour savoir si le pacman est en mouvement
  private int speed = 2;             //Vitesse du pacman

  //Variables pour les detections de collisions
  boolean midLeft = false;    //Detection du milieu du pacman côté gauche
  boolean midRight = false;   //Detection du milieu du pacman côté droite
  boolean midUp = false;      //Detection du milieu du pacman côté haut
  boolean midDown = false;    //Detection du milieu du pacman côté bas
  String angle = "";          //Detection de l'angle en collision

  //Constructeur de l'objet
  Player(int _x, int _y)
  {
    x = initx = _x;
    y = inity = _y;
    Key = Pacman.lastKey;
    collider.add(this);   //Rajout de cet objet à la liste
    ListToTable();        //Liste en tableau
  }

  //Overloading Constructeur
  Player(int _x, int _y, boolean _active)
  {
    x = initx = _x;
    y = inity = _y;
    Key = Pacman.lastKey;
    isActive = _active;
    collider.add(this);
    ListToTable();
  }

  void Update()
  {
    if (!isActive) //Test pour savoir si cet object est actif
      return;      //Sinon arrêt de la fonction

    if (pacmanState == 0) //Apparition
    {
      Direction("");
      live();
    } else if (pacmanState == 1) //Vie
    {
      if (!Key.equals(Pacman.lastKey)) //Test pour savoir si l'utilisateur a cliquer sur une nouvelle touche
      {
        Key = Pacman.lastKey;          //On change la variable Key pour la tester à la prochaine frame
        Direction(Key);                //On change la direction du joueur
      }
      Move(speed);                     //Déplacement du joueur
      Render();                        //Rendu du joueur
    } else if (pacmanState == 2)       //Mort (animation)
    {
      Direction("");                   //Changement de la direction à "" pour que le pacman ne bouge plus
      death();                         //Animation de mort
    } else if (pacmanState == 3)       //Après la Mort
    {
      changeScene(2);                  //Changement de scène (Game Over Menu)
    }
  }

  //Affichage du player
  void Render()
  {
    if (!isMoving) //S'il n'est pas en mouvement
    {
      image(Pacman.pacmanSkin[0], x, y);
      return;
    }

    //Animation de mouvement
    secondSkinStep += 0.5;   //Détermine la vitesse auquelle le pacman change d'image
    if (secondSkinStep >= 1) //Si secondSkinStep est supérieur ou égale à 1 : Changement de l'image du pacman
    {
      setSkinStep(getSkinStep() + (int)secondSkinStep); //On change l'image en changeant la variable skinStep avec les accesseurs/mutateurs
      secondSkinStep = 0;                               //On reset la variable à zero
    }

    /*
    Affichage des différentes images du pacman en fonction de skinStep et de la direction du pacman.
     A l'image zero chaque direction à la même image.
     Les images 1 et 3 sont les mêmes.
     */
    if (skinStep == 0)
      image(Pacman.pacmanSkin[0], x, y);

    if ((skinStep == 1 || skinStep == 3) && "up".equals(Direction()))
      image(Pacman.pacmanSkin[1], x, y);
    if (skinStep == 2 && "up".equals(Direction()))
      image(Pacman.pacmanSkin[2], x, y);

    if ((skinStep == 1 || skinStep == 3) && "right".equals(Direction()))
      image(Pacman.pacmanSkin[3], x, y);
    if (skinStep == 2 && "right".equals(Direction()))
      image(Pacman.pacmanSkin[4], x, y);

    if ((skinStep == 1 || skinStep == 3) && "down".equals(Direction()))
      image(Pacman.pacmanSkin[5], x, y);
    if (skinStep == 2 && "down".equals(Direction()))
      image(Pacman.pacmanSkin[6], x, y);

    if ((skinStep == 1 || skinStep == 3) && "left".equals(Direction()))
      image(Pacman.pacmanSkin[7], x, y);
    if (skinStep == 2 && "left".equals(Direction()))
      image(Pacman.pacmanSkin[8], x, y);
  }

  //Changer la direction du joueur
  String Direction(String _key)
  {
     /*
     Switch pour savoir quelle direction le joueur veut aller.
     up, left, right et down sont des boolean témoignant de la direction choisie.
     Lorsqu'une direction est choisie les autres sont automatiquement mis en "false".
     */

    switch(_key) {
    default:
    case "up":
      up = true;
      down = left = right = false;
      return "up";

    case "down":
      down = true;
      up = left = right = false;
      return "down";

    case "left":
      left = true;
      down = up = right = false;
      return "left";

    case "right":
      right = true;
      down = left = up = false;
      return "right";
    case "":
      down = left = right = up = false;
      return "";
    }//Fin switch
  }

  String Direction()
  {
    //Overloading de la fonction Direction() pour indiquer la direction voulue par le joueur.
    if (up) return "up";
    if (down) return "down";
    if (left) return "left";
    if (right) return "right";
    return "";
  }

  //Animation de mort
  void death()
  {
    if (dskinStep == 0)
      image(Pacman.pacmanSkin[1], x, y);
    else if (dskinStep == 1)
      image(Pacman.pacmanSkin[2], x, y);
    else
      image(Pacman.pacmanSkin[9 + dskinStep - 2], x, y);
      
    if (dskinStep < 12) //Si dskinStep est inférieur à 12 (condition pour ne pas dépasser la taille du tableau)
    {
      dsecondSkinStep += 1;      //Vitesse du changement d'image
      if (dsecondSkinStep >= 3)  //Si dsecondSkinStep est supérieur ou égal à 3
      {
        dsecondSkinStep = 0;     //Reset de la variable à 0
        dskinStep += 1;          //Incrémentation de la variable décidant des images à afficher
      }
    } else
    {
      dskinStep = 0;             //Reset de la variable à 0
      dsecondSkinStep = 0;       //Reset de la variable à 0
      pacmanState = 3;           //Sinon l'animation est finie : Après Mort
    }
  }

  //Animation d'apparition (Voir death() si dessus : même fonctionnement)
  void live()
  {
    if (lskinStep == 11)
      image(Pacman.pacmanSkin[2], x, y);
    else if (lskinStep == 12)
      image(Pacman.pacmanSkin[1], x, y);
    else
      image(Pacman.pacmanSkin[19-lskinStep], x, y);
    if (lskinStep < 13)
    {
      lsecondSkinStep += 1;
      if (lsecondSkinStep >= 1)
      {
        lskinStep += 1;
        lsecondSkinStep = 0;
      }
    } else
    {
      lskinStep = 0;
      lsecondSkinStep = 0;
      pacmanState = 1;
    }
  }


  //Faire bouger le joueur
  void Move(int _speed)
  { 
    /*
    Cette fonction permet de mouvoir le joueur sur la grille tout en prenant compte des collisions (murs, angles ...)
     Pour cela elle effectue une boucle qui s'incrémente de 1 jusqu'a _speed (la vitesse du pacman, le nombre de pixel qu'il parcourt en une frame).
     Chaque itération de la boucle la fonction Collide() est appellée afin de savoir les contraintes de mouvement.
     En fonction de ces contraintes des structures if décident de laisser le pacman avancer dans la direction voulue ou non.
     Deplus, si le pacman se bloque dans un pixel, il peut continuer a avancer car le code le détecte et le décale.
     */
    for (int i = 0; i < _speed; i++) {
      Collide(render1);

      if (up && canUp)          //Si la direction est égale à up et il peut aller vers le haut
        y -= 1;                 //Monte
      else if (up && !midUp)    //Sinon si la direction est égale à up et qu'il n'y a pas d'obstacle au milieu haut du pacman
        if (angle.equals("HG")) //Si l'angle est le Haut Gauche
          x++;                  //Droite
        else                    //Sinon
          x--;                  //Gauche

      if (down && canDown)      //Si la direction est égale à up et il peut aller vers le bas
        y += 1;                 //Descend
      else if (down && !midDown)//Sinon si la direction est égale à down et qu'il n'y a pas d'obstacle au milieu bas du pacman
        if (angle.equals("BG")) //Si l'angle est le Bas Gauche
          x++;                  //Droite
        else                    //Sinon
          x--;                  //Gauche

      if (left && canLeft)      //Si la direction est égale à up et il peut aller vers la gauche
        x -= 1;                 //Gauche
      else if (left && !midLeft)//Sinon si la direction est égale à left et qu'il n'y a pas d'obstacle au milieu gauche du pacman
        if (angle.equals("HG")) //Si l'angle est le Haut Gauche
          y++;                  //Descend
        else                    //Sinon
          y--;                  //Monte

      if (right && canRight)      //Si la direction est égale à right et il peut aller vers la droite
        x += 1;                   //Droite
      else if (right && !midRight)//Sinon si la direction est égale à up et qu'il n'y a pas d'obstacle au milieu bas du pacman
        if (angle.equals("HD"))   //Si l'angle est le Haut Droit
          y++;                    //Descend
        else                      //Sinon  
          y--;                    //Monte
    }

    //Ne pas faire dépasser le pacman de l'écran
    if (x < 0)
      x = 224 - 1 - pacmanSize;  //Gauche
    if (y < 0)
      y = 248 - 1 - pacmanSize; //Haut

    if (x > 224 - pacmanSize)    //Droite
      x = 0;
    if (y > 248 - pacmanSize)   //Bas
      y = 0;

    //Test pour savoir si l'objet a bouger
    if (lastx != x || lasty != y)
    {
      lastx = x;
      lasty = y;
      isMoving = true;
    } else
    {
      isMoving = false;
    }
  }

  //Fonction qui permet de savoir s'il peut bouger dans une direction précise
  void Collide(Rendered[] r) {
    /*
    Cette fonction vérifie toutes les collisions liées aux mouvements du pacman (murs, pièce ...).
     Pour cela elle utilise un tableau type Rendered ou tout les objets sont inscrits dedans.
     Ensuite une boucle permet de tester les collisions.
     Dans cette boucle est différencié les murs et les pièces ...
     */
    
    //Réinitialisation des valeurs contraintes de mouvement
    canLeft = canRight = canUp = canDown = true;
    midLeft = false;
    midRight = false;
    midUp = false;
    midDown = false;

    int rx = 0, ry = 0;
    String rID = "";
    for (Rendered render : r)  //Pour chaque objet Rendered render dans r
    {

      rx = render.getX();      //rx prend la valeur de la position x de l'objet testé
      ry = render.getY();      //ry prend la valeur de la position y de l'objet testé
      rID = render.getID();    //rID prend la valeur de l'ID de l'objet testé
      //Boucle pour test tout les pixels du Pacman
      for (int k = 0; k < pacmanSize; k++) {
        if (rID.equals("mur")) //Si l'objet testé est un mur
        { 
          if (rx == x - 1 && ry == y + k && canLeft)          //Si le mur est à gauche du pacman
            canLeft = false;

          if (rx == x + pacmanSize && ry == y + k && canRight)//Si le mur est à droite du pacman
            canRight = false;

          if (ry == y - 1 && rx == x + k && canUp)            //Si le mur est en haut du pacman
            canUp = false;

          if (ry == y + pacmanSize && rx == x + k && canDown)//Si le mur est en bas du pacman
            canDown = false;
        }
      }

      //COLLISION TYPE AABB (box to box)
      if (rID.equals("ghost_IA")) //Si l'objet est un Ghost
      {
        if ((rx >= x + 12)      //Trop à droite
          || (rx + 12 <= x)     //Trop à gauche
          || (ry >= y + 12)     //Trop en bas
          || (ry + 12 <= y))    //Trop en haut
          continue;             //Procède à la prochaine itération (pas de collision)
        else                    //Sinon
        {
          Ghost g = (Ghost) render;      //Cast du Rendered en Ghost
          if (g.ghostState == 2)         //Si l'état du fantôme est "panique"
          {
            score += 200;                //Incrémentation du score par 200
            g.ghostState = 3;            //Changement d'état du fantôme en mort
          } else if (g.ghostState > 2)   //Si l'état du fantôme est au dessus de la "panique" (mort)
          {
            g.ghostState = 3;            //Changement d'état du fantôme en mort
          } else if (g.ghostState == 1)  //Si le fantôme est en mode "chasse"
            pacmanState = 2;             //Changement de l'état du pacman en mort (animation)
          return;
        }
      }

      if (rID.equals("piece"))  //Si l'objet est une pièce
      {
        Piece p = (Piece)render;//Cast du Rendered en Piece
        p.Collide(x, y);        //Fonction collision de la pièce (point to box)
      }


      if (rID.equals("mur")) //Si l'objet est un mur
      {
        //Test pour les milieux
        if (((rx == x - 2 || rx == x - 1) && ry == y + pacmanSize/2) && left)
          midLeft = true;
        if ((rx == x + pacmanSize/2 && (ry == y - 1 || ry == y - 2) && up))
          midUp = true;
        if (((rx == x + pacmanSize + 1 || rx == x + pacmanSize) && ry == y + pacmanSize/2) && right)
          midRight = true;
        if ((rx == x + pacmanSize/2 && (ry == y + pacmanSize + 1 || ry == y + pacmanSize)) && down)
          midDown = true;

        //Test pour les angles
        if (rx == x - 1 && ry == y - 1)
          angle = "HG";
        if (rx == x + pacmanSize && ry == y - 1)
          angle = "HD";
        if (rx == x - 1 && ry == y + pacmanSize)
          angle = "BG";
        if (rx == x + pacmanSize && ry == y + pacmanSize)
          angle = "BD";
      }
    }
  }

  //Accesseurs
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  boolean isActive() {
    return isActive;
  }
  float getSpeed() {
    return speed;
  }
  int getSkinStep() {
    return skinStep;
  }
  int getDSkinStep() {
    return dskinStep;
  }
  String getID() {
    return ID;
  }

  //Mutateur
  void setX(int _x) {
    if (_x >= 0 && _x <= width) x = _x;
  }
  void setY(int _y) {
    if (_y >= 0 && _y <= height) y = _y;
  }
  void setActive(boolean _active) {
    isActive = _active;
  }
  void setSpeed(int _speed) {
    speed = _speed;
  }
  void setSkinStep(int _skinStep) {
    skinStep = _skinStep%4;
  }
  void setDSkinStep(int _dskinStep) {
    dskinStep = _dskinStep%4;
  }
}