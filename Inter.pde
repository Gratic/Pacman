class Inter extends Rendered
{
  private int x = 0;
  private int y = 0;
  private boolean isActive = true;
  String ID = "Inter";

  //Constructeur
  Inter(int _x, int _y, String _ID)
  {
    x = _x;
    y = _y;
    ID = _ID;
  }

  void Update()
  {
  }

  void Render()
  {
    fill(255);
    rect(x, y, 1, 1);
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