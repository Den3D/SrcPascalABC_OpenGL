{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;


// Описание направление движение
type
  Naprav = (UP, DOWN, LEFT, RIHT);

// 
type
  Snake = record
    posX : integer;
    posY : integer;
end;  

type 
  Apple = record
   posX    : integer;
   posY    : integer;
   visible : boolean;
end;  


const
  Key_W = 119; 
  Key_S = 115;
  Key_A = 97;
  Key_D = 100;
  Key_ESC = 27;
 
const
  Width = 600;
  Height = 600;
 
 
  
var  
  step : integer := 20;
  countSnake : integer := 3;
  el : array[1..100] of Snake;
  vecSnake : Naprav := UP;
  app : Apple;

//***********************************//
//  Начальные характеристики змейки  //
//***********************************//
procedure StartGames();
begin
  countSnake := 3;
  vecSnake   := UP;
  
  el[1].posX := 10 * step; 
  el[1].posY := 2 * step; 
  
  el[2].posX := 10 * step; 
  el[2].posY := 1 * step; 
  
  el[3].posX := 10 * step; 
  el[3].posY := 0 * step; 
  
end; 

//------------------------------------------------//
//---   Процедура создания яблока на поле      ---//
//------------------------------------------------//
procedure CreateApple(value: integer);
var
 x, y : integer;
 rnd : Random;
begin
  rnd := new Random();
  x := rnd.Next(0,Width div step);
  y := rnd.Next(0,Height div step);
  app.posX := x * step;
  app.posY := y * step;
  app.visible := true; 
end;


//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin  
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.3, 0.7, 0.9, 1.0); 
  GL.glEnable(gl.GL_DEPTH_TEST);
  StartGames();
end;





//****************************************************// 
//*******        Создание сетки               ********//
//****************************************************//
procedure DrawGrid();
begin
  GL.glPushMatrix();
    GL.glColor3f(0.0, 0.0, 0.0);
    GL.glBegin(GL.GL_LINES);
      for var i:= 0 to (Width div step) do begin
        GL.glVertex2f(i*step, 0);
        GL.glVertex2f(i*step, Height);
      end;
      
      for var j:= 0 to (Height div step) do begin
        GL.glVertex2f(0, j*step);
        GL.glVertex2f(Width, j*step);
      end;
      
    GL.glEnd();
  GL.glPopMatrix();
end;

procedure DrawQuad(mode : integer);
begin
  GL.glBegin(mode);
    GL.glVertex2f(0, step);
    GL.glVertex2f(0, 0);
    GL.glVertex2f(step, 0);
    GL.glVertex2f(step, step);
  GL.glEnd();
end;


//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
 GL.glLoadIdentity();
 GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);
 
 //DrawGrid();
 
 if (app.visible) then
 begin
   GL.glPushMatrix();
     GL.glColor3f(1.0, 0.0, 0.0);
     GL.glTranslatef(app.posX, app.posY, 0.000);
     DrawQuad(GL.GL_QUADS);
  GL.glPopMatrix();
 end;
 
 
 for var i:= 1 to countSnake do
 begin
   GL.glPushMatrix();
     GL.glColor3f(1.0, 1.0, 1.0);
     GL.glTranslatef(el[i].posX, el[i].posY, 0.001);
     DrawQuad(GL.GL_QUADS);
   GL.glPopMatrix();
   
   GL.glPushMatrix();
     GL.glColor3f(0.0, 0.0, 0.0);
     GL.glTranslatef(el[i].posX, el[i].posY, 0.002);
     DrawQuad(GL.GL_LINE_LOOP);
   GL.glPopMatrix();
 

   
   
 end; // snake
   
  Glut.glutSwapBuffers;
  Glut.glutPostRedisplay();
end;

//****************************************************// 
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(w, h: integer);
begin

 gl.glViewport(0,0, w, h);
 gl.glMatrixMode(gl.GL_PROJECTION);
 gl.glLoadIdentity();
 GLU.gluOrtho2D(0, w, 0, h);
 gl.glMatrixMode(gl.GL_MODELVIEW);
 gl.glLoadIdentity();

end;

//****************************************************// 
//****   Процедура обработки нажатия клавишь      ****//
//****************************************************// 
procedure pressKey ( key : byte; x, y : integer );
begin
 case key of
  Key_W  : if not(vecSnake = DOWN ) then  vecSnake := UP;   
  Key_S  : if not(vecSnake = UP )   then  vecSnake := DOWN;
  Key_A  : if not(vecSnake = RIHT ) then  vecSnake := LEFT;
  Key_D  : if not(vecSnake = LEFT ) then  vecSnake := RIHT;
  Key_ESC : glut.glutLeaveMainLoop(); 
 // else writeln( key );
 end;

end;

//------------------------------------------------//
//---  Обработка столкновении головы с яблоком ---//
//------------------------------------------------//
function isCollisionApple():boolean;
begin
  if ((el[1].posX = app.posX)and(el[1].posY = app.posY)) then
    isCollisionApple := true else isCollisionApple:= false;
end;

//------------------------------------------------//
//-  Функция таймер, обработка событий на сцене  -//
//------------------------------------------------//
procedure Update(value : integer);
begin
  
  for var i := 2 to countSnake do
    if ((el[1].posX = el[i].posX) and (el[1].posY = el[i].posY)) then
      StartGames();
  
  // проверка на столкновение змейки и яблока
  if ( isCollisionApple() and (app.visible)) then
  begin
    app.visible := false;
    countSnake += 1;
    // countApple +=1;
    GLUT.glutTimerFunc(7000, CreateApple, 0);
  end;
  
  
  // перемещаем записи в массиве
  for var i:= countSnake downto 2 do
  begin
    el[i].posY := el[i-1].posY;
    el[i].posX := el[i-1].posX;
  end;
   
  // перемещаем голову змеи
  case (vecSnake) of
   UP   : el[1].posY += step;
   DOWN : el[1].posY -= step;
   RIHT : el[1].posX += step;
   LEFT : el[1].posX -= step;
  end;
  
  // Следим за границами экрана
  if ( el[1].posX > Width  ) then el[1].posX := 0;
  if ( el[1].posX < 0      ) then el[1].posX := Width;
  if ( el[1].posY > Height ) then el[1].posY := 0;
  if ( el[1].posY < 0      ) then el[1].posY := Height;
   
 
  Glut.glutTimerFunc(600, Update, 0);
end;


//****************************************************// 
//********             MAIN PROGRAM            *******//
//****************************************************// 
begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(Width, Height);
  
  Glut.glutInitWindowPosition((Glut.glutGet(glut.GLUT_SCREEN_WIDTH) - Width) div 2,
                              (Glut.glutGet(glut.GLUT_SCREEN_HEIGHT) - Height) div 2);
                              
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('Snake2D Games');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  
  Glut.glutTimerFunc(600, Update, 0);
  Glut.glutTimerFunc(600, CreateApple, 0);
  
  
  glut.glutKeyboardFunc ( pressKey );
  
  InitScene();
  Glut.glutMainLoop();
end.
