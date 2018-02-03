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
  
  gl.glEnable(gl.GL_DEPTH_TEST);
 // gl.glDepthFunc(gl.GL_LEQUAL);
 // gl.glDepthRange(0.0, 1.0);
 // gl.glDepthMask(gl.GL_TRUE);
 // gl.glClearDepth(1.0);
  
end;

//****************************************************// 
//***   Процедура отрисовки                        ***//
//***   Данная процедура вызывается каждый кадр    ***//
//****************************************************// 
procedure RenderScene();
begin
  GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);
   
   GL.glRotatef(r, 0.0, 1.0, 0.0); 
   
  GL.glBegin(GL.GL_TRIANGLES);
     gl.glColor3f (1.0,   0.0, 0.0);
     gl.glVertex3f(-0.9,  0.9, 0.0);
     gl.glVertex3f(-0.9, -0.9, 0.0);
     gl.glVertex3f( 0.9, -0.9, 0.0);
        
     gl.glColor3f ( 0.0,  1.0, 0.5);
     gl.glVertex3f( 0.9,  0.9, 0.5);
     gl.glVertex3f( 0.9, -0.9, 0.5);
     gl.glVertex3f(-0.9, -0.9, -0.5);
  GL.glEnd();
  
    r := r + 0.03;
  
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
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  InitScene();
  Glut.glutMainLoop();
end.
