class Ghost extends Rendered
{
  //Déclaration des variables
  //Variables concernants les caractéristiques du joueur
  String ID = "ghost_IA";
  private int x = 0;                 //Position en x
  private int y = 0;                 //Position en y
  private int initx = 0;             //Position initiale en x
  private int inity = 0;             //Position initiale en y
  private int lastx = 0;             //Dernière position en x
  private int lasty = 0;             //Dernière position en y
  private boolean isMoving = false;  //Si l'objet bouge
  private boolean isActive = true;   //Si l'objet est actif ou non (i.e. s'il est affiché ou non)
  private int skinStep = 0;          //Variable indicant l'image à afficher pour le joueur (chasse)
  private float secondSkinStep = 0;  //Vitesse de changement d'image
  private int panicSkinStep = 0;     //Variable indicant l'image à afficher pour le joueur (panique)
  private float secondPanicSkinStep = 0;//Vitesse de changement d'image
  private int panicTimer = 5;        //Temps de "panique"
  private float secondPanicTimer = 0;//Variable pour mesurée le temps écoulée
  private int deathTimer = 5;        //Temps de "mort"
  private float secondDeathTimer = 0;//Variable pour mesurée le temps écoulée
  private int liveTimer = 3;         //Temps pour apparaître
  private float secondLiveTimer = 0; //Variable pour mesurée le temps écoulée
  private int ghostSize = 12;        //Taille du fantôme
  private int ghostType = 0;         //Type du fantôme
  private int ghostState = 0;        //Etat du fantôme

  //Variables concernants les mouvements du joueur
  private boolean up = false, down = false, left = false, right = false;
  private int speed = 1; //Vitesse du fantôme

  private Player p;      //Variable qui contiendra une référence au pacman

  //Constructeur de l'objet
  Ghost(int _x, int _y)
  {
    x = initx = _x;
    y = inity = _y;
    collider.add(this); //Rajout de l'objet dans la liste
    ListToTable();      //Passage de liste à tableau
  }

  //Overloading Constructeur
  Ghost(int _x, int _y, int _ghostType, boolean _active)
  {
    x = initx = _x;
    y = inity = _y;
    ghostType = _ghostType;
    isActive = _active;
    collider.add(this); //Rajout de l'objet dans la liste
    ListToTable();      //Passage de liste à tableau
  }

  void Update()  //Voir Pacman_Perso : Rendered
  {
    if (!isActive) //Test pour savoir si cet object est désactivé
      return;      //Arrêt de la fonction

    if (ghostState == 0)  //Apparition
    {
      live();      //Animation Vie
      Render();    //Affichage
    }
    if (ghostState == 1) //Chasse
    {
      Move(speed, Collide(render1)); //Déplacement du ghost
      Render();                      //Affichage
    }
    if (ghostState == 2) //Panique
    {
      Panic();                        //Animation Panique
      Move(speed, Collide(render1));  //Déplacement du ghost
    }
    if (ghostState == 3) //Mort
    {
      Death();                        //Animation de mort
    }

    if (p == null) //Si p n'est pas référencé
    {
      String rID = "";
      for (Rendered render : render1) //Pour tout les objets Rendered render dans render1
      {
        rID = render.getID();
        if (rID.equals("pacman"))  //Si l'objet est un pacman
        {
          p = (Player) render;     //On référence le pacman dans p
        }//FIN IF
      }//FIN FOR
    }//FIN IF
  }//FIN UPDATE

  //Animation de mort
  void Death()
  {
    int gotox = initx - x; //Calcul sa position en x par rapport à sa position en x initiale
    int gotoy = inity - y; //Calcul sa position en y par rapport à sa position en y initiale

    if (abs(gotox) - abs(gotoy) > 0) //Si la différence absolu en x est plus importante qu'en y
    {
      if (gotox > 0)               //Si le fantôme est à gauche de sa position initiale
        image(ghostEyes[3], x, y); //Yeux à droite
      else
        image(ghostEyes[2], x, y); //Yeux à gauche
    } else
    {
      if (gotoy > 0)               //Si le fantôme est en haut de sa position initiale
        image(ghostEyes[1], x, y); //Yeux en bas
      else
        image(ghostEyes[0], x, y); //Yeux en haut
    }

    if (gotox > 0)         //Si le fantôme est à gauche de sa position initiale
    {
      x += 1;              //Droite
    } else if (gotox != 0) //Sinon si gotox différent de 0
    {
      x -= 1;              //Gauche
    }

    if (gotoy > 0)         //Si le fantôme est en haut de sa position initiale
    {
      y += 1;              //Descend
    } else if (gotoy != 0) //Sinon si gotoy différent de 0
    {
      y -= 1;              //Monte
    }

    if (gotox == 0 && gotoy == 0) //Si gotox et gotoy égaux à 0
    {
      secondDeathTimer += 3;      //Incrémentation du chrono (3 car 1/30 = 0.0333...)
      if ((int)secondDeathTimer >= deathTimer*100)  //Si le chrono est supérieur à deathTimer * 100;
      {
        ghostState = 1;        //Changement d'état en mode "chasse"
        secondDeathTimer = 0;  //Réinitialisation du chrono
      }//FIN IF
    }//FIN IF
  }//FIN Death()

  //Animation de panique
  void Panic()
  {
    image(ghostPanic[panicSkinStep], x, y); //Affichage de l'image
    secondPanicSkinStep += 1;               //Incrémentation de la variable qui sert de chrono
    if (secondPanicSkinStep >= 5)           //Si secondPanicSkinStep supérieur ou égale à 5
    {
      panicSkinStep = (panicSkinStep + 1) % 4;  //panicSkinStep prend la valeur panicSkinStep + 1 puis modulo 4 (car 4 images de paniques)
      secondPanicSkinStep = 0;                  //Réinitialisation de la variable chrono skin
    }

    secondPanicTimer += 3;                      //Incrémentation de la variable chrono de l'état de panique
    if ((int)secondPanicTimer >= panicTimer*100)//Si la variable chrono de l'état de panique est supérieur à panicTimer * 100
    {
      ghostState = 1;                           //Changement d'état à l'état "Chasse"
      secondPanicTimer = 0;                     //Reset de la variable chrono
    }
  }

  //Animation d'apparition
  void live()
  {
    secondLiveTimer += 3;                      //Incrémentation de la variable chrono
    if ((int)secondLiveTimer >= liveTimer*100) //Si la variable chrono supérieur ou égale à liveTimer * 100
    {
      ghostState = 1;                          //Changement d'état à l'état "Chasse"
      secondLiveTimer = 0;                     //Réinitialisation de la variable chrono
    }
  }

  //Affiche le joueur
  void Render()
  {
    //Pour savoir quelles images afficher
    secondSkinStep += 0.5;  //Incrémentation de la variable permettant de réguler la vitesse de changement d'image
    if (secondSkinStep >= 1)//Si secondSkinStep supérieur ou égale à 1
    {
      setSkinStep(getSkinStep() + (int)secondSkinStep); //Incrémentation de skinStep
      secondSkinStep = 0;                               //Reset de la variable chrono
    }

    //Affichage du ghost en fonction du skinStep et de la direction
    if (ghostType == 0) {
      if ((skinStep == 1) && "up".equals(Direction()))
        image(pinkGhostSkin[2], x, y);
      if ((skinStep == 0) && "up".equals(Direction()))
        image(pinkGhostSkin[3], x, y);

      if ((skinStep == 1 ) && "right".equals(Direction()))
        image(pinkGhostSkin[6], x, y);
      if ((skinStep == 0) && "right".equals(Direction()))
        image(pinkGhostSkin[7], x, y);

      if ((skinStep == 1 ) && "down".equals(Direction()))
        image(pinkGhostSkin[0], x, y);
      if ((skinStep == 0) && "down".equals(Direction()))
        image(pinkGhostSkin[1], x, y);

      if ((skinStep == 1 ) && "left".equals(Direction()))
        image(pinkGhostSkin[4], x, y);
      if ((skinStep == 0) && "left".equals(Direction()))
        image(pinkGhostSkin[5], x, y);
    }

    if (ghostType == 1) {
      if ((skinStep == 1 ) && "up".equals(Direction()))
        image(redGhostSkin[2], x, y);
      if ((skinStep == 0) && "up".equals(Direction()))
        image(redGhostSkin[3], x, y);

      if ((skinStep == 1 ) && "right".equals(Direction()))
        image(redGhostSkin[6], x, y);
      if ((skinStep == 0) && "right".equals(Direction()))
        image(redGhostSkin[7], x, y);

      if ((skinStep == 1 ) && "down".equals(Direction()))
        image(redGhostSkin[0], x, y);
      if ((skinStep == 0) && "down".equals(Direction()))
        image(redGhostSkin[1], x, y);

      if ((skinStep == 1 ) && "left".equals(Direction()))
        image(redGhostSkin[4], x, y);
      if ((skinStep == 0) && "left".equals(Direction()))
        image(redGhostSkin[5], x, y);
    }

    if (ghostType == 2) {
      if ((skinStep == 1 ) && "up".equals(Direction()))
        image( blueGhostSkin[2], x, y);
      if ((skinStep == 0) && "up".equals(Direction()))
        image( blueGhostSkin[3], x, y);

      if ((skinStep == 1 ) && "right".equals(Direction()))
        image( blueGhostSkin[6], x, y);
      if ((skinStep == 0) && "right".equals(Direction()))
        image( blueGhostSkin[7], x, y);

      if ((skinStep == 1 ) && "down".equals(Direction()))
        image( blueGhostSkin[0], x, y);
      if ((skinStep == 0) && "down".equals(Direction()))
        image( blueGhostSkin[1], x, y);

      if ((skinStep == 1 ) && "left".equals(Direction()))
        image( blueGhostSkin[4], x, y);
      if ((skinStep == 0) && "left".equals(Direction()))
        image( blueGhostSkin[5], x, y);
    }

    if (ghostType == 3) {
      if ((skinStep == 1 ) && "up".equals(Direction()))
        image(yellowGhostSkin[2], x, y);
      if ((skinStep == 0) && "up".equals(Direction()))
        image(yellowGhostSkin[3], x, y);

      if ((skinStep == 1 ) && "right".equals(Direction()))
        image(yellowGhostSkin[6], x, y);
      if ((skinStep == 0) && "right".equals(Direction()))
        image(yellowGhostSkin[7], x, y);

      if ((skinStep == 1 ) && "down".equals(Direction()))
        image(yellowGhostSkin[0], x, y);
      if ((skinStep == 0) && "down".equals(Direction()))
        image(yellowGhostSkin[1], x, y);

      if ((skinStep == 1 ) && "left".equals(Direction()))
        image(yellowGhostSkin[4], x, y);
      if ((skinStep == 0) && "left".equals(Direction()))
        image(yellowGhostSkin[5], x, y);
    }
  }

  //Changer la direction du joueur
  String Direction(String _dir)
  {
    switch(_dir) {
    default:
      return "";
    case "up":
      up = true;
      down = left = right = false;
      return "up";//Renvoie de la valeur "up"

    case "down":
      down = true;
      up = left = right = false;
      return "down";//Renvoie de la valeur "down"

    case "left":
      left = true;
      down = up = right = false;
      return "left";//Renvoie de la valeur "left"

    case "right":
      right = true;
      down = left = up = false;
      return "right";//Renvoie de la valeur "right"
    }//FIN SWITCH
  }

  String Direction() // Voir Direction Player
  {
    if (up) return "up";//Renvoie de la valeur "up"
    if (down) return "down";//Renvoie de la valeur "down"
    if (left) return "left";//Renvoie de la valeur "left"
    if (right) return "right";//Renvoie de la valeur "right"
    return "";
  }

  //Faire bouger le joueur
  void Move(int _speed, String _inter)
  { 

    for (int i = 0; i < _speed; i++) //Pour chaque mouvement
    {
      Collide(render1); //Detection des intersections

      Direction(_inter);//Direction du fantôme

      if (up)
        y -= 1;

      if (down)
        y += 1;

      if (left)
        x -= 1;

      if (right)
        x += 1;
    }


    //Ne pas faire dépasser l'objet de l'écran
    if (x < 0)
      x = 224 - 1 - ghostSize;  //Gauche
    if (y < 0)
      y = 248 - 1 - ghostSize; //Haut

    if (x > 224 - ghostSize)    //Droite
      x = 0;
    if (y > 248 - ghostSize)   //Bas
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

  String Collide(Rendered[] r) {
    /* 
     Fonction qui permet la détection des nodes "Inter" dans le but de déplacer le fantôme.
     Selon les nodes le fantômes à des choix de déplacement différent.
     Selon le type de fantôme pas la même intelligence artificielle est appliquée.
     0 ou Rose  -> Random
     1 ou Rouge -> En fonction de la dernière touche appuiyée
     2 ou Bleu  -> En fonction de la position relative
     3 ou Jaune -> En fonction de la position relative et random si dans l'incapacité de se déplacer dans la bonne direction
     */

    if (p == null) //Si le pacman n'est pas référencé
      return "";   //Arrêt de la fonction, renvoie d'une valeur ""

    int soustx = p.lastx - x;  //Position relative en x
    int sousty = p.lasty - y;  //Position relative en y

    int random = 0;                  //Initialisation d'une variable random
    int rx = 0, ry = 0;              //Position des objets
    String rID = "";                 //ID des objets
    String _direction = Direction(); //Direction du fantôme

    for (Rendered render : r) //Pour chaque objet Rendered render dans r
    {
      //On rempli les variables rx, ry, rID avec les caractéristiques de l'objet
      rx = render.getX();
      ry = render.getY();
      rID = render.getID();


      if (rx == x + 7 && ry == y + 8 ) //Si l'objet est à la position x + 7 et y + 8 du fantôme
      {
        if (ghostType == 0 ) //Si ghostType est égale à 0
        {
          if (rID.equals("InterLB"))//Si l'intersection est un LB
          {
            if (_direction.equals("left"))//Si la direction vaut "left"
              return "up";                //Renvoie de la valeur "up"
            else
              return "right";             //Renvoie de la valeur "right"
          }

          if (rID.equals("InterLHG"))//Si l'intersection est un LHG
          {
            if (_direction.equals("up"))//Si la direction vaut "up"
              return "left";              //Renvoie de la valeur "left"
            else
              return "down";              //Renvoie de la valeur "down"
          }

          if (rID.equals("InterX"))       //Si l'intersection est un X
          {
            random = int(random(3));      //Random prend une valeur entière comprise entre [0;3[

            if (_direction.equals("up"))  //Si la direction vaut "up"
            {
              if (random == 0)            //Si random vaut 0
                return "up";              //Renvoie de la valeur "up"
              else if (random == 1)       //Si random vaut 1
                return "left";            //Renvoie de la valeur "left"
              else if (random == 2)       //Si random vaut 2
                return "right";           //Renvoie de la valeur "right"
            } else if (_direction.equals("right"))//Si la direction vaut "right"
            {
              if (random == 0)                     //Si random vaut 0
                return "down";                     //Renvoie de la valeur "down"
              else if (random == 1)                //Si random vaut 1
                return "right";                    //Renvoie de la valeur "right"
              else if (random == 2)                //Si random vaut 2
                return "up";                       //Renvoie de la valeur "up"
            } else if (_direction.equals("down"))//Si la direction vaut "down"
            {
              if (random == 0)                   //Si random vaut 0
                return "down";                   //Renvoie de la valeur "down"
              else if (random == 1)              //Si random vaut 1
                return "left";                   //Renvoie de la valeur "left"
              else if (random == 2)              //Si random vaut 2
                return "right";                  //Renvoie de la valeur "right"
            } else if (_direction.equals("left"))//Si la direction vaut "left" 
            {
              if (random == 0)      //Si random vaut 0
                return "down";      //Renvoie de la valeur "down"
              else if (random == 1) //Si random vaut 1
                return "up";        //Renvoie de la valeur "up"
              else if (random == 2) //Si random vaut 2
                return "left";      //Renvoie de la valeur "left"
            }
          }

          if (rID.equals("InterTH"))             //Si l'intersection est un TH 
          {
            random = int(random(2));             //Random prend une valeur entière comprise entre [0;2[

            if (_direction.equals("down"))       //Si la direction vaut "down" 
            {
              if (random == 0)                   //Si random vaut 0
                return "left";                   //Renvoie de la valeur "left"
              else if (random == 1)              //Si random vaut 1
                return "right";                  //Renvoie de la valeur "right"
            } else if (_direction.equals("left"))//Si la direction vaut "left" 
            {
              if (random == 0)                    //Si random vaut 0
                return "up";                      //Renvoie de la valeur "up"
              else if (random == 1)               //Si random vaut 1
                return "left";                    //Renvoie de la valeur "left"
            } else if (_direction.equals("right"))//Si la direction vaut "right" 
            {
              if (random == 0)           //Si random vaut 0
                return "right";          //Renvoie de la valeur "right"
              else if (random == 1)      //Si random vaut 1
                return "up";             //Renvoie de la valeur "up"
            }
          }

          if (rID.equals("InterTD"))     //Si l'intersection est un TD 
          {
            random = int(random(2));     //Random prend une valeur entière comprise entre [0;2[

            if (_direction.equals("up")) //Si la direction vaut "up" 
            {
              if (random == 0)                   //Si random vaut 0
                return "up";                     //Renvoie de la valeur "up"
              else if (random == 1)              //Si random vaut 1
                return "right";                  //Renvoie de la valeur "right"
            } else if (_direction.equals("down"))//Si la direction vaut "down" 
            {
              if (random == 0)                   //Si random vaut 0
                return "down";                   //Renvoie de la valeur "down"
              else if (random == 1)              //Si random vaut 1
                return "right";                  //Renvoie de la valeur "right"
            } else if (_direction.equals("left"))//Si la direction vaut "left" 
            {
              if (random == 0)     //Si random vaut 0
                return "down";     //Renvoie de la valeur "down"
              else if (random == 1)//Si random vaut 1
                return "up";       //Renvoie de la valeur "up"
            }
          }

          if (rID.equals("InterTG"))             //Si l'intersection est un TG 
          { 
            random = int(random(2));             //Random prend une valeur entière comprise entre [0;2[

            if (_direction.equals("up"))         //Si la direction vaut "up" 
            {
              if (random == 0)                   //Si random vaut 0
                return "up";                     //Renvoie de la valeur "up"
              else if (random == 1)              //Si random vaut 1
                return "left";                   //Renvoie de la valeur "left"
            } else if (_direction.equals("down"))//Si la direction vaut "down" 
            {
              if (random == 0)                    //Si random vaut 0
                return "down";                    //Renvoie de la valeur "down"
              else if (random == 1)               //Si random vaut 1
                return "left";                    //Renvoie de la valeur "left"
            } else if (_direction.equals("right"))//Si la direction vaut "right" 
            {
              if (random == 0)     //Si random vaut 0
                return "down";     //Renvoie de la valeur "down"
              else if (random == 1)//Si random vaut 1
                return "up";       //Renvoie de la valeur "up"
            }
          }

          if (rID.equals("InterTB"))      //Si l'intersection est un TB 
          { 
            random = int(random(2));      //Random prend une valeur entière comprise entre [0;2[

            if (_direction.equals("up"))  //Si la direction vaut "up" 
            {
              if (random == 0)     //Si random vaut 0
                return "right";    //Renvoie de la valeur "right"
              else if (random == 1)//Si random vaut 1
                return "left";     //Renvoie de la valeur "left"
            }
            if (_direction.equals("right"))//Si la direction vaut "right" 
            {
              if (random == 0)     //Si random vaut 0
                return "down";     //Renvoie de la valeur "down"
              else if (random == 1)//Si random vaut 1
                return "right";    //Renvoie de la valeur "right"
            }
            if (_direction.equals("left"))//Si la direction vaut "left" 
            {
              if (random == 0)     //Si random vaut 0
                return "left";     //Renvoie de la valeur "left"
              else if (random == 1)//Si random vaut 1
                return "down";     //Renvoie de la valeur "down"
            }
          }

          if (rID.equals("InterLBG"))      //Si l'intersection est un LBG 
          { 

            if (_direction.equals("right"))//Si la direction vaut "right"
              return "up";                 //Renvoie de la valeur "up"
            else
              return "left";               //Renvoie de la valeur "left"
          }

          if (rID.equals("InterLH"))    //Si l'intersection est un LH 
          { 

            if (_direction.equals("up"))//Si la direction vaut "up"
              return "right";           //Renvoie de la valeur "right"
            else
              return "down";            //Renvoie de la valeur "down"
          }

          if (rID.equals("InterU"))//Si l'intersection est un U 
          { 
            return "up";           //Renvoie de la valeur "up"
          }

          if (rID.equals("InterR"))//Si l'intersection est un R
          { 
            return "right";        //Renvoie de la valeur "right"
          }

          if (rID.equals("InterL"))//Si l'intersection est un L 
          { 
            return "left";         //Renvoie de la valeur "left"
          }

          if (rID.equals("InterLR"))    //Si l'intersection est un LR 
          {
            if (_direction.equals("up"))//Si la direction vaut "up"
            {
              random = int(random(2));  //Random prend une valeur entière comprise entre [0;2[
              if (random == 0)          //Si random vaut 0
                return "left";          //Renvoie de la valeur "left"
              else
                return "right";         //Renvoie de la valeur "right"
            }

            if (_direction.equals("left"))//Si la direction vaut "left"
              return "left";              //Renvoie de la valeur "left"
            else
              return "right";             //Renvoie de la valeur "right"
          }
        }//FIN DU GHOSTTYPE 0

        if (ghostType == 1)
        {
          if (rID.equals("InterLB"))//Si l'intersection est un LB 
          {
            if (Droite)             //Si la dernière direction du joueur est Droite
            {
              return "right";       //Renvoie de la valeur "right"
            } else if (Haut)        //Si la dernière direction du joueur est Haut
            {
              return "up";          //Renvoie de la valeur "up"
            } else 
            {
              if (_direction.equals("left"))//Si la direction vaut "left"
                return "up";                //Renvoie de la valeur "up"
              else
                return "right";             //Renvoie de la valeur "right"
            }
          }

          if (rID.equals("InterLHG"))    //Si l'intersection est un LHG 
          {
            if (Gauche)                  //Si la dernière direction du joueur est Gauche
            {
              return "left";             //Renvoie de la valeur "left"
            } else if (Bas)              //Si la dernière direction du joueur est Bas
            {
              return "down";             //Renvoie de la valeur "down"
            } else 
            {
              if (_direction.equals("up"))//Si la direction vaut "up"
                return "left";            //Renvoie de la valeur "left"
              else
                return "down";            //Renvoie de la valeur "down"
            }
          }

          if (rID.equals("InterX"))//Si l'intersection est un X 
          {

            if (Gauche)            //Si la dernière direction du joueur est Gauche
            {
              return "left";       //Renvoie de la valeur "left"
            } else if (Bas)        //Si la dernière direction du joueur est Bas
            {
              return "down";       //Renvoie de la valeur "down"
            } else if (Haut)       //Si la dernière direction du joueur est Haut
            {
              return "up";         //Renvoie de la valeur "up"
            } else
            {
              return "right";      //Renvoie de la valeur "right"
            }
          }

          if (rID.equals("InterTH"))//Si l'intersection est un TH 
          {
            if (Gauche)             //Si la dernière direction du joueur est Gauche
            {
              return "left";        //Renvoie de la valeur "left"
            } else if (Haut)        //Si la dernière direction du joueur est Haut
            {
              return "up";          //Renvoie de la valeur "up"
            } else if (Droite)      //Si la dernière direction du joueur est Droite
            {
              return "right";       //Renvoie de la valeur "right"
            } else {
              random = int(random(2));      //Random prend une valeur entière comprise entre [0;2[

              if (_direction.equals("down"))//Si la direction vaut "down"
              {
                if (random == 0)                   //Si random vaut 0
                  return "left";                   //Renvoie de la valeur "left"
                else if (random == 1)              //Si random vaut 1
                  return "right";                  //Renvoie de la valeur "right"
              } else if (_direction.equals("left"))//Si la direction vaut "left" 
              {
                if (random == 0)                    //Si random vaut 0
                  return "up";                      //Renvoie de la valeur "up"
                else if (random == 1)               //Si random vaut 1
                  return "left";                    //Renvoie de la valeur "left"
              } else if (_direction.equals("right"))//Si la direction vaut "right" 
              {
                if (random == 0)                    //Si random vaut 0
                  return "right";                   //Renvoie de la valeur "right"
                else if (random == 1)               //Si random vaut 1
                  return "up";                      //Renvoie de la valeur "up"
              }
            }
          }

          if (rID.equals("InterTD"))  //Si l'intersection est un TD 
          {
            if (Bas)                  //Si la dernière direction du joueur est Bas
            {
              return "down";          //Renvoie de la valeur "down"
            } else if (Haut)          //Si la dernière direction du joueur est Haut
            {
              return "up";            //Renvoie de la valeur "up"
            } else if (Droite)        //Si la dernière direction du joueur est Droite
            {
              return "right";         //Renvoie de la valeur "right"
            } else {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[

              if (_direction.equals("up"))         //Si la direction vaut "up" 
              {
                if (random == 0)                   //Si random vaut 0
                  return "up";                     //Renvoie de la valeur "up"
                else if (random == 1)              //Si random vaut 1
                  return "right";                  //Renvoie de la valeur "right"
              } else if (_direction.equals("down"))//Si la direction vaut "down" 
              {
                if (random == 0)                   //Si random vaut 0
                  return "down";                   //Renvoie de la valeur "down"
                else if (random == 1)              //Si random vaut 1
                  return "right";                  //Renvoie de la valeur "right"
              } else if (_direction.equals("left"))//Si la direction vaut "left" 
              {
                if (random == 0)                   //Si random vaut 0
                  return "down";                   //Renvoie de la valeur "down"
                else if (random == 1)              //Si random vaut 1
                  return "up";                     //Renvoie de la valeur "up"
              }
            }
          }

          if (rID.equals("InterTG"))//Si l'intersection est un TG 
          { 

            if (Bas)                //Si la dernière direction du joueur est Bas
            {
              return "down";        //Renvoie de la valeur "down"
            } else if (Haut)        //Si la dernière direction du joueur est Haut
            {
              return "up";          //Renvoie de la valeur "up"
            } else if (Gauche)      //Si la dernière direction du joueur est Gauche
            {
              return "left";        //Renvoie de la valeur "left"
            } else {

              random = int(random(2));             //Random prend une valeur entière comprise entre [0;2[

              if (_direction.equals("up"))         //Si la direction vaut "up" 
              {
                if (random == 0)                   //Si random vaut 0
                  return "up";                     //Renvoie de la valeur "up"
                else if (random == 1)              //Si random vaut 1
                  return "left";                   //Renvoie de la valeur "left"
              } else if (_direction.equals("down"))//Si la direction vaut "down" 
              {
                if (random == 0)                    //Si random vaut 0
                  return "down";                    //Renvoie de la valeur "down"
                else if (random == 1)               //Si random vaut 1
                  return "left";                    //Renvoie de la valeur "left"
              } else if (_direction.equals("right"))//Si la direction vaut "right" 
              {
                if (random == 0)       //Si random vaut 0
                  return "down";       //Renvoie de la valeur "down"
                else if (random == 1)  //Si random vaut 1
                  return "up";         //Renvoie de la valeur "up"
              }
            }
          }

          if (rID.equals("InterTB"))  //Si l'intersection est un TB 
          { 
            if (Droite)               //Si la dernière direction du joueur est Droite
            {
              return "right";         //Renvoie de la valeur "right"
            } else if (Bas)           //Si la dernière direction du joueur est Bas
            {
              return "down";          //Renvoie de la valeur "down"
            } else if (Gauche)        //Si la dernière direction du joueur est Gauche
            {
              return "left";          //Renvoie de la valeur "left"
            } else {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[

              if (_direction.equals("up"))//Si la direction vaut "up" 
              {
                if (random == 0)          //Si random vaut 0
                  return "right";         //Renvoie de la valeur "right"
                else if (random == 1)     //Si random vaut 1
                  return "left";          //Renvoie de la valeur "left"
              }
              if (_direction.equals("right"))//Si la direction vaut "right" 
              {
                if (random == 0)             //Si random vaut 0
                  return "down";             //Renvoie de la valeur "down"
                else if (random == 1)        //Si random vaut 1
                  return "right";            //Renvoie de la valeur "right"
              }
              if (_direction.equals("left")) //Si la direction vaut "left" 
              {
                if (random == 0)     //Si random vaut 0
                  return "left";     //Renvoie de la valeur "left"
                else if (random == 1)//Si random vaut 1
                  return "down";     //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterLBG"))        //Si l'intersection est un LBG 
          { 
            if (Haut)                        //Si la dernière direction du joueur est Haut
            {
              return "up";                   //Renvoie de la valeur "up"
            } else if (Gauche)               //Si la dernière direction du joueur est Gauche
            {
              return "left";                 //Renvoie de la valeur "left"
            } else {
              if (_direction.equals("right"))//Si la direction vaut "right"
                return "up";                 //Renvoie de la valeur "up"
              else
                return "left";               //Renvoie de la valeur "left"
            }
          }
          if (rID.equals("InterLH"))  //Si l'intersection est un LH { 
            if (Droite)               //Si la dernière direction du joueur est Droite
            {
              return "right";         //Renvoie de la valeur "right"
            } else if (Bas)           //Si la dernière direction du joueur est Bas
            {
              return "down";          //Renvoie de la valeur "down"
            } else {

              if (_direction.equals("up"))//Si la direction vaut "up"
                return "right";           //Renvoie de la valeur "right"
              else
                return "down";            //Renvoie de la valeur "down"
            }

          if (rID.equals("InterU"))//Si l'intersection est un U 
          { 
            return "up";           //Renvoie de la valeur "up"
          }

          if (rID.equals("InterR"))//Si l'intersection est un R 
          { 
            return "right";        //Renvoie de la valeur "right"
          }

          if (rID.equals("InterL"))//Si l'intersection est un L 
          { 
            return "left";         //Renvoie de la valeur "left"
          }

          if (rID.equals("InterLR"))//Si l'intersection est un LR 
          {
            if (_direction.equals("up") && Droite)
              return "right";//Renvoie de la valeur "right"
            else
              return "left";//Renvoie de la valeur "left"
          }
        }//FIN DU GHOSTTYPE 1

        if (ghostType == 2) 
        {
          if (rID.equals("InterLB"))//Si l'intersection est un LB 
          {
            if (p.lasty<y)          //Si la position en y du pacman est inférieur à la position en y du ghost
            {
              return "up";          //Renvoie de la valeur "up"
            } else if (p.lastx > x)//Si la position en x du pacman est supérieur à la position en x du ghost
            {
              return "right";       //Renvoie de la valeur "right"
            } else 
            {
              if (_direction.equals("left"))//Si la direction vaut "left"
              {
                return "up";                //Renvoie de la valeur "up"
              } else
              {
                return "right";             //Renvoie de la valeur "right"
              }
            }
          }

          if (rID.equals("InterLBG"))//Si l'intersection est un LBG 
          {
            if (p.lasty<y)           //Si la position en y du pacman est inférieur à la position en y du ghost
            {
              return "up";           //Renvoie de la valeur "up"
            } else if (p.lastx<x)    //Si la position en x du pacman est inférieur à la position en x du ghost
            {
              return "left";         //Renvoie de la valeur "left"
            } else 
            {
              if (_direction.equals("left"))//Si la direction vaut "left"
              {
                return "up";                //Renvoie de la valeur "up"
              } else
              {
                return "left";              //Renvoie de la valeur "left"
              }
            }
          }

          if (rID.equals("InterLHG"))//Si l'intersection est un LHG 
          {
            if (p.lasty > y)         //Si la position en y du pacman est supérieur à la position en y du ghost
            {
              return "down";         //Renvoie de la valeur "down"
            } else if (p.lastx<x)    //Si la position en x du pacman est inférieur à la position en x du ghost
            {
              return "left";         //Renvoie de la valeur "left"
            } else 
            {
              if (_direction.equals("up"))//Si la direction vaut "up"
              {
                return "left";            //Renvoie de la valeur "left"
              } else
              {
                return "down";            //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterLH"))//Si l'intersection est un LH 
          {
            if (p.lasty>y)          //Si la position en y du pacman est supérieur à la position en y du ghost
            {
              return"down";
            } else if (p.lastx > x)//Si la position en x du pacman est supérieur à la position en x du ghost
            {
              return "right";       //Renvoie de la valeur "right"
            } else 
            {
              if (_direction.equals("up"))//Si la direction vaut "up"
              {
                return "right";           //Renvoie de la valeur "right"
              } else
              {
                return "down";            //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterX"))       //Si l'intersection est un X 
          {
            if (abs(soustx) > abs(sousty))//Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)//Si la position en x du pacman est supérieur à la position en x du ghost              
              {
                return "right";           //Renvoie de la valeur "right"
              } else if (p.lastx<x)       //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";            //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTH"))      //Si l'intersection est un TH 
          {
            if (abs(soustx) > abs(sousty))//Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)            //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";           //Renvoie de la valeur "right"
              } else if (p.lastx<x)       //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";            //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) <= abs(sousty))//Si la différence en x est inférieure ou égal à la différence en y
            {
              if (p.lasty > y)                    //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                if (p.lastx > x)                  //Si la position en x du pacman est supérieur à la position en x du ghost
                {
                  return "right";                 //Renvoie de la valeur "right"
                } else if (p.lastx < x)           //Si la position en x du pacman est supérieur à la position en x du ghost
                {
                  return "left";                  //Renvoie de la valeur "left"
                }
              } else if (p.lasty < y)             //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                      //Renvoie de la valeur "up"
              }
            }
          }

          if (rID.equals("InterTD"))        //Si l'intersection est un TD 
          {
            if (abs(soustx) > abs(sousty))  //Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)              //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";             //Renvoie de la valeur "right"
              } else if (p.lastx<x)         //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                if (p.lasty<y)              //Si la position en y du pacman est inférieur à la position en y du ghost
                {
                  return "up";              //Renvoie de la valeur "up"
                } else if (p.lasty>y)       //Si la position en y du pacman est supérieur à la position en y du ghost
                {
                  return "down";            //Renvoie de la valeur "down"
                }
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTG"))      //Si l'intersection est un TG 
          {
            if (abs(soustx) > abs(sousty))//Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx < x)            //Si la position en x du pacman est supérieur à la position en y du ghost
              {
                return "left";            //Renvoie de la valeur "left"
              } else if (p.lastx > x)     //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                if (p.lasty<y)            //Si la position en y du pacman est inférieur à la position en y du ghost
                {
                  return "up";            //Renvoie de la valeur "up"
                } else if (p.lasty>y)     //Si la position en y du pacman est supérieur à la position en y du ghost
                {
                  return "down";          //Renvoie de la valeur "down"
                }
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTB"))      //Si l'intersection est un TB 
          {
            if (abs(soustx) > abs(sousty))//Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)            //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";           //Renvoie de la valeur "right"
              } else if (p.lastx<x)       //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";            //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) <= abs(sousty))//Si la différence en x est inférieure ou égal à la différence en y
            {
              if (p.lasty < y)                    //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                if (p.lastx > x)                  //Si la position en x du pacman est supérieur à la position en x du ghost
                {
                  return "right";                 //Renvoie de la valeur "right"
                } else if (p.lastx < x)           //Si la position en x du pacman est supérieur à la position en y du ghost
                {
                  return "left";                  //Renvoie de la valeur "left"
                }
              } else if (p.lasty > y)             //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                    //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterU"))//Si l'intersection est un U 
          { 
            return "up";//Renvoie de la valeur "up"
          }

          if (rID.equals("InterR"))//Si l'intersection est un R 
          { 
            return "right";//Renvoie de la valeur "right"
          }

          if (rID.equals("InterL"))//Si l'intersection est un L 
          { 
            return "left";//Renvoie de la valeur "left"
          }

          if (rID.equals("InterLR"))//Si l'intersection est un LR
          {
            if (soustx > 0)
              return "right";//Renvoie de la valeur "right"
            else
              return "left";//Renvoie de la valeur "left"
          }
        }//FIN DU GHOSTTYPE 2

        if (ghostType == 3) {
          if (rID.equals("InterLB"))//Si l'intersection est un LB 
          {
            if (p.lasty<y)          //Si la position en y du pacman est inférieur à la position en y du ghost
            {
              return "up";          //Renvoie de la valeur "up"
            } else if (p.lastx > x) //Si la position en x du pacman est supérieur à la position en x du ghost
            {
              return "right";       //Renvoie de la valeur "right"
            } else 
            {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[
              if (random == 0)        //Si random vaut 0
                return "up";          //Renvoie de la valeur "up"
              else if (random == 1)   //Si random vaut 1
                return "right";       //Renvoie de la valeur "right"
            }
          }

          if (rID.equals("InterLBG"))//Si l'intersection est un LBG 
          {
            if (p.lasty<y)           //Si la position en y du pacman est inférieur à la position en y du ghost
            {
              return "up";           //Renvoie de la valeur "up"
            } else if (p.lastx<x)    //Si la position en x du pacman est inférieur à la position en y du ghost
            {
              return "left";         //Renvoie de la valeur "left"
            } else 
            {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[
              if (random == 0)        //Si random vaut 0
                return "up";          //Renvoie de la valeur "up"
              else if (random == 1)   //Si random vaut 1
                return "left";        //Renvoie de la valeur "left"
            }
          }

          if (rID.equals("InterLHG"))//Si l'intersection est un LHG 
          {
            if (p.lasty > y)         //Si la position en y du pacman est supérieur à la position en y du ghost
            {
              return "down";         //Renvoie de la valeur "down"
            } else if (p.lastx<x)    //Si la position en x du pacman est inférieur à la position en y du ghost
            {
              return "left";         //Renvoie de la valeur "left"
            } else 
            {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[
              if (random == 0)        //Si random vaut 0
                return "down";        //Renvoie de la valeur "down"
              else if (random == 1)   //Si random vaut 1
                return "left";        //Renvoie de la valeur "left"
            }
          }

          if (rID.equals("InterLH"))//Si l'intersection est un LH 
          {
            if (p.lasty>y)          //Si la position en y du pacman est supérieur à la position en y du ghost
            {
              return "down";        //Renvoie de la valeur "down"
            } else if (p.lastx > x) //Si la position en x du pacman est supérieur à la position en x du ghost
            {
              return "right";       //Renvoie de la valeur "right"
            } else 
            {
              random = int(random(2));//Random prend une valeur entière comprise entre [0;2[
              if (random == 0)        //Si random vaut 0
                return "down";        //Renvoie de la valeur "down"
              else if (random == 1)   //Si random vaut 1
                return "right";       //Renvoie de la valeur "right"
            }
          }

          if (rID.equals("InterX"))         //Si l'intersection est un X 
          {
            if (abs(soustx) > abs(sousty))  //Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)              //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";             //Renvoie de la valeur "right"
              } else if (p.lastx<x)         //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";              //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTH"))              //Si l'intersection est un TH 
          {
            if (abs(soustx) > abs(sousty))        //Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)                    //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";                   //Renvoie de la valeur "right"
              } else if (p.lastx<x)               //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";                    //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) <= abs(sousty))//Si la différence en x est inférieure ou égal à la différence en y
            {
              if (p.lasty > y)                    //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                random = int(random(3));          //Random prend une valeur entière comprise entre [0;3[
                if (random == 0)                  //Si random vaut 0
                  return "up";                    //Renvoie de la valeur "up"
                else if (random == 1)             //Si random vaut 1
                  return "right";                 //Renvoie de la valeur "right"
                else if (random == 2)             //Si random vaut 2
                  return "left";                  //Renvoie de la valeur "left"
              } else if (p.lasty < y)             //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                      //Renvoie de la valeur "up"
              }
            }
          }


          if (rID.equals("InterTD"))        //Si l'intersection est un TD 
          {
            if (abs(soustx) > abs(sousty))  //Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)              //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";             //Renvoie de la valeur "right"
              } else if (p.lastx<x)         //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                {
                  random = int(random(3));  //Random prend une valeur entière comprise entre [0;3[
                  if (random == 0)          //Si random vaut 0
                    return "up";            //Renvoie de la valeur "up"
                  else if (random == 1)     //Si random vaut 1
                    return "right";         //Renvoie de la valeur "right"
                  else if (random == 2)     //Si random vaut 2
                    return "down";          //Renvoie de la valeur "down"
                }
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTG"))        //Si l'intersection est un TG 
          {
            if (abs(soustx) > abs(sousty))  //Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx < x)              //Si la position en x du pacman est supérieur à la position en y du ghost
              {
                return "left";              //Renvoie de la valeur "left"
              } else if (p.lastx > x)       //Si la position en x du pacman est supérieur à la position en x du ghost

              {
                random = int(random(3));  //Random prend une valeur entière comprise entre [0;3[
                if (random == 0)          //Si random vaut 0
                  return "up";            //Renvoie de la valeur "up"
                else if (random == 1)     //Si random vaut 1
                  return "left";          //Renvoie de la valeur "left"
                else if (random == 2)     //Si random vaut 2
                  return "down";          //Renvoie de la valeur "down"
              }
            } else if (abs(soustx) < abs(sousty))//Si la différence en x est inférieur à la différence en y
            {
              if (p.lasty<y)                     //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                return "up";                     //Renvoie de la valeur "up"
              } else if (p.lasty>y)              //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                   //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterTB"))      //Si l'intersection est un TB 
          {
            if (abs(soustx) > abs(sousty))//Si la différence en x est supérieur à la différence en y
            {
              if (p.lastx > x)            //Si la position en x du pacman est supérieur à la position en x du ghost
              {
                return "right";           //Renvoie de la valeur "right"
              } else if (p.lastx<x)       //Si la position en x du pacman est inférieur à la position en y du ghost
              {
                return "left";            //Renvoie de la valeur "left"
              }
            } else if (abs(soustx) <= abs(sousty))  //Si la différence en x est inférieure ou égal à la différence en y
            {
              if (p.lasty < y)                      //Si la position en y du pacman est inférieur à la position en y du ghost
              {
                random = int(random(3));            //Random prend une valeur entière comprise entre [0;3[
                if (random == 0)                    //Si random vaut 0
                  return "right";                   //Renvoie de la valeur "right"
                else if (random == 1)               //Si random vaut 1
                  return "left";                    //Renvoie de la valeur "left"
                else if (random == 2)               //Si random vaut 2
                  return "down";                    //Renvoie de la valeur "down"
              } else if (p.lasty > y)               //Si la position en y du pacman est supérieur à la position en y du ghost
              {
                return "down";                      //Renvoie de la valeur "down"
              }
            }
          }

          if (rID.equals("InterU"))//Si l'intersection est un U 
          { 
            return "up";//Renvoie de la valeur "up"
          }

          if (rID.equals("InterR"))//Si l'intersection est un R 
          { 
            return "right";//Renvoie de la valeur "right"
          }

          if (rID.equals("InterL"))//Si l'intersection est un L 
          { 
            return "left";//Renvoie de la valeur "left"
          }

          if (rID.equals("InterLR"))//Si l'intersection est un LR
          {
            if (soustx > 0)
              return "right";//Renvoie de la valeur "right"
            else
              return "left";//Renvoie de la valeur "left"
          }
        }//FIN DU GHOSTTYPE 3
      }// FIN IF POSITION (INTERSECTION)
    } //FIN FOR
    return "";
  }// FIN DE LA FONCTION 

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
    skinStep = _skinStep%2;
  }
}