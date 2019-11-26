class Mur extends Rendered
{
  private int x = 0;
  private int y = 0;
  private boolean isActive = true;
  String ID = "mur";

  Mur(int _x, int _y)
  {
    x = _x;
    y = _y;
  }

  void Update()
  {
  }

  void Render()
  {
    fill(243);
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