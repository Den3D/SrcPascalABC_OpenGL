{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

var
  r: single;
  
//****************************************************// 
//***  Инициализация ресурсов приложения и OpenGL  ***//
//****************************************************// 
procedure InitScene();
begin  
  Writeln( GL.glGetString(GL.GL_VERSION));
  GL.glClearColor(0.0, 0.0, 0.0, 0.0); 
end;

//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
  GL.glClear(GL.GL_COLOR_BUFFER_BIT);
   
  GL.glBegin(GL.GL_QUADS); 
    GL.glColor3f(0.0, 1.0, 0.0);
    GL.glVertex2f(-0.3, 0.3);
  
    GL.glColor3f(1.0, 0.0, 0.0);
    GL.glVertex2f(-0.9,  -0.9);
  
    GL.glColor3f(0.0, 0.0, 1.0);
    GL.glVertex2f( 0.2, -0.5);
  
  
    GL.glColor3f(0.0, 0.0, 1.0);
    GL.glVertex2f( 0.9, 0.9);
  GL.glEnd();
  
  //GL.glFinish();
  Glut.glutSwapBuffers;
end;

//****************************************************// 
//*** Процедура таймер.                            ***//
//*** Вызывается каждые 40 мсек для отрисовка кадра **//
//****************************************************// 
procedure Timer(val: integer);
begin
  Glut.glutPostRedisplay();
  Glut.glutTimerFunc(40, Timer, 0);
end;

//****************************************************// 
//***  Процедура перенастройки                     ***//
//***  Проц. вызыв. при изменении размера экрана   ***//
//****************************************************//
procedure Reshape(w, h: integer);
begin

end;


begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(400, 300);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  InitScene();
  Glut.glutMainLoop();
end.
