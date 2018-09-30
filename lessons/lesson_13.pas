{$reference Tao.FreeGlut.dll}
{$reference Tao.OpenGl.dll}

uses
   System, System.Collections.Generic, System.Linq, System.Text, 
   Tao.OpenGl, Tao.FreeGlut;

const
  Width = 600;
  Height = 480;

var
  r  : single  := 0.0;
  r1 : single  := 0.0;
  r2 : single  := 0.0;
  b  : boolean := false;

//****************************************************// 
//*******      Процедура создания куба      **********//
//****************************************************// 
procedure DrawCube();
begin
  // front
  GL.glColor3f(1.0, 0.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2 
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4
  GL.glEnd();
 
  // back
  GL.glColor3f(0.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
  GL.glEnd();
  
  // left
  GL.glColor3f(0.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2 
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
  GL.glEnd();
  
  // right
  GL.glColor3f(1.0, 1.0, 0.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4    
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
  GL.glEnd();
   
  // top
  GL.glColor3f(1.0, 0.0, 1.0);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f( -2.0,  2.0,  2.0); // 1
    gl.glVertex3f(  2.0,  2.0,  2.0); // 4    
    gl.glVertex3f(  2.0,  2.0, -2.0); // 8
    gl.glVertex3f( -2.0,  2.0, -2.0); // 5
  GL.glEnd();

  // down
  GL.glColor3f(0.5, 0.0, 0.5);
  GL.glBegin(GL.GL_QUADS);
    gl.glVertex3f(  2.0, -2.0,  2.0); // 3
    gl.glVertex3f( -2.0, -2.0,  2.0); // 2  
    gl.glVertex3f( -2.0, -2.0, -2.0); // 6
    gl.glVertex3f(  2.0, -2.0, -2.0); // 7
  GL.glEnd();
end;

procedure DrawHuman();
begin

    // тело 1-2
    GL.glPushMatrix(); 
     // 1
     GL.glPushMatrix();
       GL.glTranslatef(0.0, 0.0, 0.0);
       GL.glColor3f(0.9, 0.1, 0.6);
       GLUT.glutSolidCube(1.0);
     GL.glPopMatrix();
     // 2
     GL.glPushMatrix();
       GL.glTranslatef(0.0, -1.0, 0.0);
       GL.glColor3f(0.9, 0.1, 0.6);
       GLUT.glutSolidCube(1.0);
     GL.glPopMatrix();
     
     GL.glPopMatrix(); // 1-2 
    
    // пр. рука
    GL.glPushMatrix();
    GL.glColor3f(0.9, 0.6, 0.6);
    GL.glTranslatef(1.0, 0.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();
    
    // лев. рука
    GL.glPushMatrix();
    GL.glColor3f(0.9, 0.6, 0.1);
    GL.glTranslatef(-1.0, 0.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();
    
    // голова
    GL.glPushMatrix();
    GL.glColor3f(0.1, 0.6, 0.1);
    GL.glTranslatef(0.0, 1.0, 0.0);
    GLUT.glutSolidCube(1.0);
    GL.glPopMatrix();
    


end;
  
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
 GL.glLoadIdentity();
 //GL.glTranslatef(0.0, -2.0, 0.0);
 
 Glu.gluLookAt( 0.0, 0.0, 10.0,
                0.0, 0.0, 0.0,
                0.0, 1.0, 0.0);

  GL.glClear(GL.GL_COLOR_BUFFER_BIT or GL.GL_DEPTH_BUFFER_BIT);

  GL.glPushMatrix();
    GL.glTranslatef(0.0, 2.0, 0.0);
    GL.glRotatef(r, 0.0, 0.0, 1.0); 
    GL.glColor3f(0.5, 0.5, 0.3);
    GLUT.glutSolidCube(1.0);
  GL.glPopMatrix();  
  
  GL.glPushMatrix();
    GL.glTranslatef(3.0, 0.0, 0.0);
    GL.glRotatef(r1, 0.0, 0.0, 1.0); 
    GL.glColor3f(0.2, 0.7, 0.3);
    GLUT.glutSolidCube(1.0);
  GL.glPopMatrix();
 
  GL.glPushMatrix();
    GL.glTranslatef(-3.0, 0.0, 0.0);
    GL.glRotatef(r2, 0.0, 0.0, 1.0); 
    GL.glColor3f(0.9, 0.1, 0.6);
    GLUT.glutSolidCube(1.0);
  GL.glPopMatrix();
  
 {  
 GL.glPushMatrix(); 
  GL.glTranslatef(-3.0, 0.0, 0.0);
  DrawHuman();
 GL.glPopMatrix();
 } 
  r := r + 1.0;
  r1 := r1 - 1.0;
  r2 := r2 - 1.0;
  
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

 gl.glViewport(0,0, w, h);
 gl.glMatrixMode(gl.GL_PROJECTION);
 gl.glLoadIdentity();
 
 glu.gluPerspective(45, w/h, 0.1, 10000.0);

 
 gl.glMatrixMode(gl.GL_MODELVIEW);
 gl.glLoadIdentity();

end;


begin
  Glut.glutInit(); 
  Glut.glutInitWindowSize(Width, Height);
  Glut.glutInitWindowPosition(300, 200); 
  Glut.glutInitDisplayMode(GLUT.GLUT_RGBA or Glut.GLUT_DOUBLE or GLUT.GLUT_DEPTH);
  Glut.glutCreateWindow('Tao Example');  
  Glut.glutDisplayFunc(RenderScene);
  Glut.glutReshapeFunc(Reshape);
  Glut.glutTimerFunc(40, Timer, 0);
  InitScene();
  Glut.glutMainLoop();
end.
