class Piece extends Rendered
{
  private int x = 0;
  private int y = 0;
  private boolean isActive = true;
  String ID = "piece";
  String type = ""; //Type de pièce (piece ou Gpiece)

  //Constructeur
  Piece(int _x, int _y, String _type)
  {
    x = _x;
    y = _y;
    type = _type;
  }

  void Update()
  {
    if (isActive) //Si l'objet est actif
    {
      Render();   //Affichage de l'objet
    }
  }
  
  //Affichage de l'objet
  void Render()
  {
    noStroke();               //Enlève les contours
    if (type.equals("piece")) //Si c'est une pièce
    {
      fill(255, 255, 0);      //Jaune
      rect(x, y, 1, 1);       //Rectangle en x et y, de taille 1 par 1 (carré)
    } else if (type.equals("Gpiece")) //Si c'est une pièce spéciale
    {
      fill(255, 255, 0);      //Jaune
      rect(x-1, y-1, 3, 3);   //Rectangle en x-1 et y-1 de taille 3 x 3 (carré)
    }
  }

  //Collision
  boolean Collide(int px, int py)
  {
    if (!isActive) //Si l'objet est inactif
      return false;  //Arrêt de la fonction, renvoie d'un boolean faux

    if (x <= px + 12 //Si x inférieur à px + 12 (taille du pacman)
      && x >= px     //et x supérieur à px
      && y <= py + 12//et y inférieur à py + 12 (taille du pacman)
      && y >= py)    //et y supérieur à py
    {
      isActive = false; //Désactivation de la pièce
      score++;          //Incrémentation du score par 1

      if (type.equals("Gpiece")) //Si la pièce est une Gpiece
      {
        String rID = "";
        for (Rendered render : render1)  //Pour tout les objets Rendered render dans render1
        {
          rID = render.getID();
          if (rID.equals("ghost_IA"))    //Si l'objet est un fantôme
          {
            Ghost g = (Ghost)render;     //Cast du Rendered en Ghost
            if (g.ghostState == 1)       //Si l'état du fantôme est "chasse"
            {
              g.ghostState = 2;          //Changement d'état en "panique"
            }
            g.secondPanicTimer = 0;      //Réinitialisation du chrono "panique"
          }
        }// FIN FOR
      }// FIN IF
      return true;   //Collision
    } else
      return false;  //Pas collision
  }

  //Accesseurs
  int getX() {
    return x;
  }

  int getY() {
    return y;
  }
  String getID() {
    return ID;
  }


  //Mutateurs
  void setX (int _x)
  {
    x = _x;
  }

  void setY (int _y)
  {
    y = _y;
  }

  void setActive(boolean active)
  {
    isActive = active;
  }
}