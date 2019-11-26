import controlP5.*; //Importation de la librairie ControlP5

//Variables d'état du jeu
static int sceneIndex = 0; //Menu actuel du jeu
static String lastKey = "";//Dernière touche appuyée

//Tableaux des skins
static PImage[] pacmanSkin = new PImage[20];
static PImage[] pinkGhostSkin = new PImage[8];
static PImage[] redGhostSkin = new PImage[8];
static PImage[] blueGhostSkin = new PImage[8];
static PImage[] yellowGhostSkin = new PImage[8];
static PImage[] ghostPanic = new PImage[4];
static PImage[] ghostEyes = new PImage[4];

//direction du joueur
static boolean Haut = false;
static boolean Bas = false;
static boolean Droite = false;
static boolean Gauche = false;

//Variables et tableau pour le score / highscore / pièce
static int score = 0;
static int nombreDePiece = 0;

// Déclaration variable pour le traitement de fichier (aka sauvegarde)
String lignes[];     //Tableau contenant les lignes du fichier
PrintWriter fichier; //On déclare l'objet fichier pour pouvoir écrire dans le fichier
int nbLignes;        //On déclare une variable entière pour le nombre de lignes du fichier scores.txt

//Grille de jeu
PImage imgBackground = new PImage();
PImage imgPiece = new PImage();
PImage imgIA = new PImage();
PImage imgMenu = new PImage();

ArrayList<Rendered> collider = new ArrayList<Rendered>(); //Liste de tout les Rendered
Rendered[] render1 = new Rendered[0];                     //Tableau de tout les Rendered

//ControlP5
ControlP5 cp5;

//Textes
Textarea zoneScore;           
Textarea zoneHighscore;
Textarea zoneTitreHighscore;
Textarea GameOver;
Textarea scoreGameOver;
//Saisie de texte
Textfield zonePseudo;          
//Boutons
Button btnStart;              
Button btnMenu;
Button btnReplay;

//Déclarations des variables, Objets
Player player = new Player(105, 87);
Ghost pghost = new Ghost(95-7, 116-8, 0, true);
Ghost rghost = new Ghost(104-7, 116-8, 1, true);
Ghost bghost = new Ghost(119-7, 116-8, 2, true);
Ghost jghost = new Ghost(128-7, 116-8, 3, true);

//Fonction éxécuté au lancement du programme
void setup()
{
  cp5 = new ControlP5(this);
  size(350, 248);   //Taille de la fenêtre
  background(255);  //Couleur du fond
  frameRate(30);    //Limitation des frames par secondes
  loadSkin();       //Chargement des images des personnages
  loadMap("Images\\grille1.png", "Images\\grille1piece.png", "Images\\grille1ia.png"); //Chargement de l'environnement
  imgMenu = loadImage("Images\\Menu_fini.png"); //Image du Menu

  //Instanciation des contrôle CP5
  btnStart = cp5.addButton("Start")
    .setPosition(125, 120) //Position
    .setSize(100, 20)      //Taille
    .setColorBackground(color(150, 140, 0)) //Couleur du background (fond)
    ;

  btnReplay = cp5.addButton("Replay")
    .setPosition(63, 170)
    .setSize(100, 30)
    .setColorBackground(color(150, 140, 0))
    .setColorForeground(color(0))
    .setVisible(false)
    ;

  btnMenu = cp5.addButton("Menu")
    .setPosition(187, 170)
    .setSize(100, 30)
    .setColorBackground(color(150, 140, 0))
    .setColorForeground(color(0))
    .setVisible(false)
    ;

  zoneScore = cp5.addTextarea("zoneScore")
    .setPosition(102, 0)
    .setSize(126, 50)
    .setFont(createFont("arial", 15))
    .setLineHeight(17)
    .setColor(color(255))
    .setColorBackground(color(255, 0))
    .setColorForeground(color(255))
    .setVisible(true)
    ;

  zoneTitreHighscore = cp5.addTextarea("zoneTitreHighscore")
    .setPosition(240, 0)                //Position
    .setSize(106, 35)                   //Taille
    .setFont(createFont("arial", 15))   //Taille de police
    .setLineHeight(17)                  //Taille interligne
    .setColor(color(255))               //Couleur du texte
    .setColorBackground(color(150, 0))  //Couleur BG
    .setColorForeground(color(255))
    .setText("HIGHSCORE")               //Texte
    .setVisible(true)                   //Visible ou non
    ;

  zoneHighscore = cp5.addTextarea("zoneHighscore")
    .setPosition(224, 20) // position du coin supérieur gauche de la textbox
    .setSize(130, 180) // largeur et hauteur
    .setFont(createFont ("arial", 10)) // type et taille de la police
    .setLineHeight(15) // hauteur de chaque ligne dans la zone d'affichage
    .setColor(color(0)) // couleur de la police
    .setColorBackground(color(255)) // couleur de fond de la zone d'affichage
    .setColorForeground(color(255))// couleur de premier plan 
    ;

  scoreGameOver = cp5.addTextarea("scoreGameOver")
    .setPosition(63, 70) // position du coin supérieur gauche de la textbox
    .setSize(200, 40) // largeur et hauteur
    .setFont(createFont ("arial", 20)) // type et taille de la police
    .setLineHeight(1) // hauteur de chaque ligne dans la zone d'affichage
    .setColor(color(255)) // couleur de la police
    .setColorBackground(color(0)) // couleur de fond de la zone d'affichage
    .setColorForeground(color(255, 255, 0))// couleur de premier plan 
    .setText("Score: " + score)
    .setVisible(false);
  ;

  GameOver = cp5.addTextarea("GameOver")
    .setPosition(63, 20) // position du coin supérieur gauche de la textbox
    .setSize(200, 40) // largeur et hauteur
    .setFont(createFont ("arial", 30)) // type et taille de la police
    .setLineHeight(1) // hauteur de chaque ligne dans la zone d'affichage
    .setColor(color(255, 255, 0)) // couleur de la police
    .setColorBackground(color(0)) // couleur de fond de la zone d'affichage
    .setColorForeground(color(255, 255, 0))// couleur de premier plan 
    .setText("GAME OVER")
    .setVisible(false);
  ;

  zonePseudo = cp5.addTextfield("zonePseudo")
    .setPosition(63, 109)
    .setSize(224, 30)
    .setFocus(true)
    .setColorCursor(color(0))
    .setColor(color(255, 255, 0))
    .setColorForeground(color(255, 255, 0))
    .setColorBackground(color(0))
    .setFont(createFont("arial", 14))
    ;

  lignes = loadStrings("scores.txt"); //Tableau contenant les lignes de "scores.txt"
  nbLignes = lignes.length;           //On note le nombre de lignes
  changeScene(0);                     //Variable pour les changements de scène
  tri(lignes);                        //Tri (bulle) du tableau contenant les scores
}

//Fonction éxécuté chaque frame
void draw()
{
  //Choix de la scène
  switch(sceneIndex) {
  default:
  case 0: //Menu Principal
    image(imgMenu, 0, 0);                  //Affichage de l'image
    return;
  case 1: //Jeu
    //Redessine le plateau
    //Pour que le score soit centré
    if (score < 10)
      zoneScore.setPosition(106, 0);
    else if (score < 100)
      zoneScore.setPosition(102, 0);
    else
      zoneScore.setPosition(98, 0);

    image(imgBackground, 0, 0);        //Affichage de la grille
    //Exécute les fonctions des Rendered
    for (Rendered render : collider)
    {
      render.Update();
    }

    //Test pour savoir si le joueur à "avaler" toutes les pièces
    String rID = "";
    int nombreDePieceInactives = 0;
    for (Rendered render : render1)  //Pour chaque objet Rendered render dans render1 
    {
      rID = render.getID();          //Récuperation l'ID
      if (rID.equals("piece"))       //Test de l'ID
      {
        Piece p = (Piece) render;    //Cast en Piece
        if (p.isActive == true)      //Test pour savoir si la pièce a été ramassé
        {
          break;                     //Non donc stop la boucle
        } else
        {
          nombreDePieceInactives ++; //On incrémente la variable comptant le nombre de pièce inactive
        }
      }
    }
    if (nombreDePieceInactives == nombreDePiece) //Si le nombre de pièce inactives est égal au nombre de pièce sur la grille
    {
      Restart();                                 //Recommencer
    }

    zoneScore.setText(str(score));  //Affichage du score
    return;
  case 2: //Game Over Menu
    background(0);                    //Fond Noir
    return;
  }
}

void tri(String tableau[])
{
  boolean echange = true;  //Boolean indiquant si le tri est fini
  int temp;                //Variable Tempon
  String nomTemp;          //Variable Tempon
  while (echange)          //Tant que le tri n'est pas fini
  {
    echange = false;
    for (int i = 0; i< nbLignes - 2; i+=2)      //Toute les deux lignes (car "pseudo" \n "score")
    {
      if (int(tableau[i+1])< int(tableau[i+3])) //Si le score du premier est inférieur au deuxième
      {
        nomTemp = tableau[i];         //Mise en tempon du nom
        temp = int(tableau[i+1]);     //Mise en tempon du nombre
        tableau[i] = tableau[i+2];    //Le nom prend le nom du tableau i+2
        tableau[i+1] = tableau[i+3];  //De même la valeur
        tableau[i+2] = nomTemp;       //Le nom i+2 prend la valeur nomTemp
        tableau[i+3] = str(temp);     //La valeur i+3 prend la valeur int(temp)
        echange = true;
      } // FIN IF
    } // FIN FOR
  } // FIN WHILE
  String reponse = "";//Chaine initialisée à vide pour afficher le tableau trié dans la console

  for (int i=0; i<20; i +=2)//i<20 car on ne veut que le 10 meilleurs scores, or chaque score prenne 2 lignes donc 2X10 = 20lignes
  {
    if (i < lignes.length)
    {
      reponse += lignes[i] + " : " + lignes[i+1] + "\n"; //On affiche les meilleurs scores dans notre zone d'affichage
    }
  }//FIN FOR
  zoneHighscore.setText(reponse); //On affiche "reponse" dans la zone de texte "zoneScore"
  Sauvegarder();                  //Sauvegarde du score trier dans le fichier
}

void Sauvegarder()
{
  fichier = createWriter("scores.txt");  //On crée fichier "scores.txt"
  for (int i = 0; i < nbLignes; i++)     //Pour chaque ligne
  {
    fichier.println(lignes[i]);          //On écrit chaque ligne
  }
  fichier.flush();                       //On actualise le fichier
  fichier.close();                       //On ferme le fichier
  lignes = loadStrings("scores.txt");    //On charge les lignes du fichier
  nbLignes = lignes.length;              //On note le nombre de lignes
}

void Enregistrer()
{
  fichier = createWriter("scores.txt");  //On crée fichier "scores.txt"
  for (int i = 0; i < nbLignes; i++)     //Pour chaque ligne
  {
    fichier.println(lignes[i]);          //On écrit chaque ligne
  }
  fichier.println(zonePseudo.getText()); //Puis on écrit le pseudo
  fichier.println(str(score));           //Et le score
  fichier.flush();                       //On actualise le fichier
  fichier.close();                       //On ferme le fichier
  lignes = loadStrings("scores.txt");    //On charge les lignes du fichier
  nbLignes = lignes.length;              //On note le nombre de lignes
  tri(lignes);
}

//Dès qu'un bouton est appuyé
void keyPressed()
{
  //Si la touche appuyé est reconnue
  if (key == CODED)
  {   
    //Reconnaissance des flèches directionnelles du clavier
    if (keyCode == UP)
    {
      lastKey = "up";    //haut
      Haut = true;
      Bas = false;
      Droite = false;
      Gauche = false;
    }
    if (keyCode == DOWN)
    {
      lastKey = "down";  //bas
      Bas = true;
      Gauche = false;
      Haut = false;
      Droite = false;
    }
    if (keyCode == LEFT)
    {
      lastKey = "left";  //gauche
      Droite = false;
      Bas = false;
      Gauche = true;
      Haut = false;
    }
    if (keyCode == RIGHT)
    {
      lastKey = "right"; //droite
      Gauche = false;
      Bas = false;
      Haut = false;
      Droite  = true;
    }
  }
}

void loadSkin() {
  //Remplissage des tableaux avec les images
  pacmanSkin[0] = loadImage("Images\\Pacman\\pacman_full.png");
  pacmanSkin[1] = loadImage("Images\\Pacman\\pacman_up1.png");
  pacmanSkin[2] = loadImage("Images\\Pacman\\pacman_up2.png");
  pacmanSkin[3] = loadImage("Images\\Pacman\\pacman_right1.png");
  pacmanSkin[4] = loadImage("Images\\Pacman\\pacman_right2.png");
  pacmanSkin[5] = loadImage("Images\\Pacman\\pacman_down1.png");
  pacmanSkin[6] = loadImage("Images\\Pacman\\pacman_down2.png");
  pacmanSkin[7] = loadImage("Images\\Pacman\\pacman_left1.png");
  pacmanSkin[8] = loadImage("Images\\Pacman\\pacman_left2.png");
  pacmanSkin[9] = loadImage("Images\\Pacman\\pacman_mort1.png");
  pacmanSkin[10] = loadImage("Images\\Pacman\\pacman_mort2.png");
  pacmanSkin[11] = loadImage("Images\\Pacman\\pacman_mort3.png");
  pacmanSkin[12] = loadImage("Images\\Pacman\\pacman_mort4.png");
  pacmanSkin[13] = loadImage("Images\\Pacman\\pacman_mort5.png");
  pacmanSkin[14] = loadImage("Images\\Pacman\\pacman_mort6.png");
  pacmanSkin[15] = loadImage("Images\\Pacman\\pacman_mort7.png");
  pacmanSkin[16] = loadImage("Images\\Pacman\\pacman_mort8.png");
  pacmanSkin[17] = loadImage("Images\\Pacman\\pacman_mort9.png");
  pacmanSkin[18] = loadImage("Images\\Pacman\\pacman_mort10.png");
  pacmanSkin[19] = loadImage("Images\\Pacman\\pacman_mort11.png");

  pinkGhostSkin[0] = loadImage("Images\\Ghost\\pink_ghost\\down_l.png");
  pinkGhostSkin[1] = loadImage("Images\\Ghost\\pink_ghost\\down_s.png");
  pinkGhostSkin[2] = loadImage("Images\\Ghost\\pink_ghost\\high_l.png");
  pinkGhostSkin[3] = loadImage("Images\\Ghost\\pink_ghost\\high_s.png");
  pinkGhostSkin[4] = loadImage("Images\\Ghost\\pink_ghost\\left_l.png");
  pinkGhostSkin[5] = loadImage("Images\\Ghost\\pink_ghost\\left_s.png");
  pinkGhostSkin[6] = loadImage("Images\\Ghost\\pink_ghost\\right_l.png");
  pinkGhostSkin[7] = loadImage("Images\\Ghost\\pink_ghost\\right_s.png");

  redGhostSkin[0] = loadImage("Images\\Ghost\\red_ghost\\down_l.png");
  redGhostSkin[1] = loadImage("Images\\Ghost\\red_ghost\\down_s.png");
  redGhostSkin[2] = loadImage("Images\\Ghost\\red_ghost\\high_l.png");
  redGhostSkin[3] = loadImage("Images\\Ghost\\red_ghost\\high_s.png");
  redGhostSkin[4] = loadImage("Images\\Ghost\\red_ghost\\left_l.png");
  redGhostSkin[5] = loadImage("Images\\Ghost\\red_ghost\\left_s.png");
  redGhostSkin[6] = loadImage("Images\\Ghost\\red_ghost\\right_l.png");
  redGhostSkin[7] = loadImage("Images\\Ghost\\red_ghost\\right_s.png");

  blueGhostSkin[0] = loadImage("Images\\Ghost\\blue_ghost\\down_l.png");
  blueGhostSkin[1] = loadImage("Images\\Ghost\\blue_ghost\\down_s.png");
  blueGhostSkin[2] = loadImage("Images\\Ghost\\blue_ghost\\high_l.png");
  blueGhostSkin[3] = loadImage("Images\\Ghost\\blue_ghost\\high_s.png");
  blueGhostSkin[4] = loadImage("Images\\Ghost\\blue_ghost\\left_l.png");
  blueGhostSkin[5] = loadImage("Images\\Ghost\\blue_ghost\\left_s.png");
  blueGhostSkin[6] = loadImage("Images\\Ghost\\blue_ghost\\right_l.png");
  blueGhostSkin[7] = loadImage("Images\\Ghost\\blue_ghost\\right_s.png");

  yellowGhostSkin[0] = loadImage("Images\\Ghost\\yellow_ghost\\down_l.png");
  yellowGhostSkin[1] = loadImage("Images\\Ghost\\yellow_ghost\\down_s.png");
  yellowGhostSkin[2] = loadImage("Images\\Ghost\\yellow_ghost\\high_l.png");
  yellowGhostSkin[3] = loadImage("Images\\Ghost\\yellow_ghost\\high_s.png");
  yellowGhostSkin[4] = loadImage("Images\\Ghost\\yellow_ghost\\left_l.png");
  yellowGhostSkin[5] = loadImage("Images\\Ghost\\yellow_ghost\\left_s.png");
  yellowGhostSkin[6] = loadImage("Images\\Ghost\\yellow_ghost\\right_l.png");
  yellowGhostSkin[7] = loadImage("Images\\Ghost\\yellow_ghost\\right_s.png");

  ghostPanic[0] = loadImage("Images\\Ghost\\ghost_panic1.png");
  ghostPanic[1] = loadImage("Images\\Ghost\\ghost_panic2.png");
  ghostPanic[2] = loadImage("Images\\Ghost\\ghost_panic3.png");
  ghostPanic[3] = loadImage("Images\\Ghost\\ghost_panic4.png");

  ghostEyes[0] = loadImage("Images\\Ghost\\ghost_eyeup.png");
  ghostEyes[1] = loadImage("Images\\Ghost\\ghost_eyedown.png");
  ghostEyes[2] = loadImage("Images\\Ghost\\ghost_eyeleft.png");
  ghostEyes[3] = loadImage("Images\\Ghost\\ghost_eyeright.png");

  //Resize des images en 12x12
  for (int i = 0; i < 20; i++)
  {
    pacmanSkin[i].resize(12, 12);
  }

  for (int i = 0; i < 8; i++)
  {
    pinkGhostSkin[i].resize(12, 12);
  }

  for (int i = 0; i < 8; i++)
  {
    redGhostSkin[i].resize(12, 12);
  }

  for (int i = 0; i < 8; i++)
  {
    blueGhostSkin[i].resize(12, 12);
  }

  for (int i = 0; i < 8; i++)
  {
    yellowGhostSkin[i].resize(12, 12);
  }

  for (int i = 0; i < 4; i++)
  {
    ghostPanic[i].resize(12, 12);
  }

  for (int i = 0; i < 4; i++)
  {
    ghostEyes[i].resize(12, 12);
  }
}



void loadMap(String pathBG, String pathPiece, String pathIA)
{
  //On charge les images
  imgBackground = loadImage(pathBG); 
  imgPiece = loadImage(pathPiece);
  imgIA = loadImage(pathIA);

  //pour chaque x
  for (int i = 0; i < imgBackground.height; i++)
  {
    //pour chaque y
    for (int j = 0; j < imgBackground.width; j++)
    {
      color couleur = imgBackground.get(j, i);
      int r = getRed(couleur);    //Rouge
      int g = getGreen(couleur);  //Vert
      int b = getBlue(couleur);   //Bleu

      //test des couleurs pour instancier un objet mur
      if (r == 0 && g == 0 && b == 255)
        collider.add(new Mur(j, i));
    }
  }

  //pour chaque x
  for (int i = 0; i < imgPiece.height; i++)
  {
    //pour chaque y
    for (int j = 0; j < imgPiece.width; j++)
    {
      color couleur = imgPiece.get(j, i);
      int r = getRed(couleur);
      int g = getGreen(couleur);
      int b = getBlue(couleur);

      //test des couleurs pour instancier un objet pièce
      if (r == 255 && g == 0 && b == 0)
      {
        collider.add(new Piece(j, i, "piece"));
        nombreDePiece++;
      }
      if (r == 255 && g == 255 && b == 255)
      {
        collider.add(new Piece(j, i, "Gpiece"));
        nombreDePiece++;
      }
    }
  }

  //pour chaque x
  for (int i = 0; i < imgIA.height; i++)
  {
    //pour chaque y
    for (int j = 0; j < imgIA.width; j++)
    {
      color couleur = imgIA.get(j, i);
      int r = getRed(couleur);
      int g = getGreen(couleur);
      int b = getBlue(couleur);

      //Instancier les nodes pour les fantômes
      if (r==220 && g == 0 && b == 0)
        collider.add(new Inter(j, i, "InterLB"));

      if (r==80 && g == 0 && b == 0)
        collider.add(new Inter(j, i, "InterLBG"));

      if (r == 0  && g == 80 && b == 0)
        collider.add(new Inter(j, i, "InterTH"));

      if (r == 0 && g == 0 && b == 80)
        collider.add(new Inter(j, i, "InterTD"));

      if (r == 0 && g == 255 && b == 0)
        collider.add(new Inter(j, i, "InterLH"));

      if (r == 0 && g == 159 && b == 0)
        collider.add(new Inter(j, i, "InterLHG"));

      if (r == 80 && g == 0 && b == 80)
        collider.add(new Inter(j, i, "InterX"));

      if (r == 255 && g == 0 && b == 255)
        collider.add(new Inter(j, i, "InterTG"));

      if (r == 0 && g == 0 && b == 250)
        collider.add(new Inter(j, i, "InterTB"));

      if (r == 250 && g == 255 && b == 112)
        collider.add(new Inter(j, i, "InterR"));

      if (r == 250 && g == 255 && b == 205)
        collider.add(new Inter(j, i, "InterL"));

      if (r == 250 && g == 255 && b == 50)
        collider.add(new Inter(j, i, "InterU"));

      if (r == 241 && g == 0 && b == 249)
        collider.add(new Inter(j, i, "InterLR"));
    }
  }
  ListToTable(); //Liste à tableau
}

void ListToTable()
{
  render1 = new Rendered[collider.size()];   //Création d'un tableau de la taille de la liste

  for (int h = 0; h < collider.size (); h++) //Pour chaque objet de la liste
  {
    render1[h] = collider.get(h);            //On le met dans le tableau
  }
}

//Changer de Menu
void changeScene(int _index)
{
  sceneIndex = _index;
  if (sceneIndex == 0) //Menu Principal
  {
    zoneHighscore.setVisible(false);
    zoneTitreHighscore.setVisible(false);
    zonePseudo.setVisible(false);
    zoneScore.setVisible(false);
    GameOver.setVisible(false);
    scoreGameOver.setVisible(false);
    btnStart.setVisible(true);
    btnReplay.setVisible(false);
    btnMenu.setVisible(false);
    btnReplay.setMouseOver(false);
    btnMenu.setMouseOver(false);
    btnStart.setMouseOver(true);
    cp5.update();
  } else if (sceneIndex == 1) //Jeu
  {
    //On active tout les objets rendered
    for (Rendered render : render1)
    {
      render.isActive = true;
    }

    zoneHighscore.setVisible(true);
    zoneTitreHighscore.setVisible(true);
    zoneScore.setVisible(true);
    zonePseudo.setVisible(false);
    btnStart.setVisible(false);
    GameOver.setVisible(false);
    scoreGameOver.setVisible(false);
    btnReplay.setVisible(false);
    btnMenu.setVisible(false);
    btnReplay.setMouseOver(false);
    btnMenu.setMouseOver(false);
    btnStart.setMouseOver(false);
    score = 0;
    cp5.update();
  } else if (sceneIndex == 2) //Game Over Menu
  {
    background(0); //Affichage d'un fond noir
    
    //On désactive tout les objets rendered
    for (Rendered render : render1)
    {
      render.isActive = false;
    }

    zoneHighscore.setVisible(false);
    zoneTitreHighscore.setVisible(false);
    zoneScore.setVisible(false);
    GameOver.setVisible(true);
    scoreGameOver.setVisible(true);
    scoreGameOver.setText("SCORE: " + score);
    zonePseudo.setVisible(true);
    zonePseudo.setFocus(true);
    zonePseudo.setVisible(true);
    btnReplay.setVisible(true);
    btnMenu.setVisible(true);
    btnReplay.setMouseOver(true);
    btnMenu.setMouseOver(true);
    btnStart.setMouseOver(false);
    cp5.update();
  }
}

void Restart()
{
  //Redémarrer une partie
  String rID = "";
  for (Rendered render : render1)
  {

    rID = render.getID();

    if (rID.equals("ghost_IA")) //Si c'est un ghost
    {
      Ghost g = (Ghost) render; //Cast du Rendered en Ghost
      g.x = g.initx;            //Repositionnement en x
      g.y = g.inity;            //Repositionnement en y
      g.ghostState = 0;         //Remise à l'état 0
    }
    if (rID.equals("piece"))    //Si c'est une pièce
    {
      Piece p = (Piece) render; //Cast du Rendered en pièce
      p.isActive = true;        //Réactivation de la pièce
    }
    if (rID.equals("pacman"))   //Si c'est le pacman
    {
      Player p = (Player) render; //Cast du Rendered en Player 
      p.x = p.initx;              //Repositionnement en x
      p.y = p.inity;              //Repositionnement en y
      p.pacmanState = 0;          //Remise à l'état 0
    }
  }
}

void Start()  //Fonction Bouton Start
{
  changeScene(1);
  Restart();
}

void Replay() //Fonction Bouton Replay
{
  if (!zonePseudo.getText().equals("")) //Si le pseudo ne vaut pas ""
  {
    Enregistrer();                      //Enregistrement du pseudo + score
  }
  Restart();                            //Recommencer la partie
  score = 0;                            //Reset le score
  changeScene(1);                       //Changer de scène (Jeu)
}

void Menu() //Fonction Bouton Menu
{
  if (!zonePseudo.getText().equals("")) //Si le pseudo ne vaut pas ""
  {
    Enregistrer();                      //Enregistrement du pseudo + score
  }
  changeScene(0);                       //Changer de scène (Menu Principal)
}

//Fonction pour retrouver la couleur d'un pixel
//La couleur est codée sur un int32
//On filtre la partie du binaire avec une opération binaire ET et un filtre Hexadécimal
//Puis on décale la partie filtré pour former un nouveau int comportant la composante de couleur voulue
int getAlpha(color _c)
{
  return (_c & 0xFF000000) >> 24;
}

int getRed(color _c)
{
  return (_c & 0x00FF0000) >> 16;
}

int getGreen(color _c)
{
  return (_c & 0x0000FF00) >> 8;
}

int getBlue(color _c)
{
  return (_c & 0x000000FF) >> 0;
}