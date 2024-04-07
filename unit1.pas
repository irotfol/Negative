unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  ComCtrls, StdCtrls, Menus;

const
     //Отступ слева для первого центра координат
     xpos1 = 480;

     //Отступ сверху для первого центра координат
     ypos1 = 160;

     //Отступ слева для второго центра координат
     xpos2 = 1020;

     //Отступ сверху для вторго центра координат
     ypos2 = 380;

     //Длина стрелок у координат
     arrow = 10;

     //Расстояние от центра координат до краев координатной плоскости
     length = 150;

     //Максимальное количество координат
     rows = 14;

type

  { TForm1 }
  coord = record
    x,y:integer;
  end;
  zveno = ^inters;
  inters = record
    amount:byte;
    next:zveno;
  end;

  XY = array[1..rows] of coord;
  TForm1 = class(TForm)
    ButtonAdd: TButton;
    ButtonDelete: TButton;
    ButtonClear: TButton;
    ButtonDraw: TButton;
    CheckBoxAxes: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelStartCount: TLabel;
    LabelAuthor: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    //function intersection(cor1,cor2,cor3,cor4:xy):boolean;
    procedure ButtonAddClick(xstr,ystr:string; Sender: TObject);
    procedure ButtonAddClick2(Sender: Tobject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonDrawClick(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);

  private

  public

  end;
var

  Form1:TForm1;
  n:integer;
  pict:boolean;
  intersections:byte;
  coordinates:xy;
  authorfile:text;
  author:string;
  point,betw:zveno;


implementation

{$R *.lfm}

{ TForm1 }

//Сохранение автора-------------------------------------------------------------
procedure TForm1.MenuItem2Click(Sender: TObject);
begin
     assignfile(authorfile, 'Author.txt');
     author:=Inputbox('Author', 'Enter author','');
     rewrite(authorfile);
     write(authorfile, author);
     closefile(authorfile);
     form1.labelauthor.Caption:='Автор: ' + author;
end;
//------------------------------------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);
var
  fil:file of integer;
  tr:integer;
begin
     author:='';
     tr:=0;
     pict:=false;

     new(point);
     point:=nil;
     n := 0;
//1.Сохранение количества запусков----------------------------------------------
     assignfile(fil, 'data.dat');
     if FileExists('data.dat') then begin
        reset(fil);
        read(fil, tr);
        closefile(fil);
     end;

     assignfile(fil, 'data.dat');
     tr:=tr+1;
     rewrite(fil);
     write(fil, tr);
     closefile(fil);
     form1.Labelstartcount.Caption:='Количество запусков программы: ' + inttostr(tr);
//1.----------------------------------------------------------------------------
//1.1Сохранение автора----------------------------------------------------------
     if FileExists('author.txt') then begin
        assignfile(authorfile, 'Author.txt');
        reset(authorfile);
        read(authorfile, author);
        closefile(authorfile);
     end;
     form1.Labelauthor.Caption:='Автор: ' + author;
//1.1---------------------------------------------------------------------------

//2.Заполнение шапки таблиц-----------------------------------------------------
with stringgrid1 do
	begin
	Cells[0,0] := 'X';
        Cells[1,0] := 'Y';
     end;

     with stringgrid2 do
	begin
	Cells[0, 0] := 'N';
        Cells[1, 0] := 'X';
        Cells[2, 0] := 'Y';
     end;

end;
//2.----------------------------------------------------------------------------

//3.Фикс для сворачивания окна--------------------------------------------------
procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
     label1.Visible:=false;
     label2.Visible:=false;
     label3.Visible:=false;
     label4.Visible:=false;
     CheckBoxAxes.checked:=false;
end;
//3.----------------------------------------------------------------------------

//4.Добавление координат--------------------------------------------------------

//4.1.Проверка координат--------------------------------------------------------
procedure TForm1.ButtonAddClick2(Sender: TObject);
var
  x,y:^string;
begin
     new(x);
     new(y);
     x^:=stringgrid1.cells[0,1];
     y^:=stringgrid1.cells[1,1];
     if x^ = '' then  x^ := '0';
     if y^ = '' then  y^ := '0';
     if not ((n > 0) and (strtoint(x^) = coordinates[n].x) and (strtoint(y^) = coordinates[n].y)) then ButtonAddClick(x^, y^, Sender)
     else showmessage('Coordinates can not be identical');
     dispose(x);
     dispose(y);
end;
//4.1.--------------------------------------------------------------------------

function intersection(cor1,cor2,cor3,cor4:coord):boolean;
var
  p:array [0..3] of integer;
begin
     p[0]:=(cor4.y - cor3.y)*(cor4.x - cor1.x)-(cor4.x - cor3.x)*(cor4.y - cor1.y);
     p[1]:=(cor4.y - cor3.y)*(cor4.x - cor2.x)-(cor4.x - cor3.x)*(cor4.y - cor2.y);
     p[2]:=(cor2.y - cor1.y)*(cor2.x - cor3.x)-(cor2.x - cor1.x)*(cor2.y - cor3.y);
     p[3]:=(cor2.y - cor1.y)*(cor2.x - cor4.x)-(cor2.x - cor1.x)*(cor2.y - cor4.y);
     if (p[0]*p[1]<=0) and (p[2]*p[3]<=0) then begin
        intersection:=true;
     end;
     intersection:=false;
end;

procedure TForm1.ButtonAddClick(xstr,ystr:string; Sender: TObject);
var
  i:integer;
begin
     //4.2.Добавление строк-----------------------------------------------------
     n := n + 1;
     stringgrid2.RowCount := n + 1;
     //4.2.---------------------------------------------------------------------


     //4.3.Включение кнопкок "Удаление строк/Очистка координат"-----------------
     if n = 1 then begin
        ButtonDelete.visible := true;
        ButtonClear.enabled := true;
     end
     else begin
         //4.3.1.Визуал для кнопки удаление строки(сдвиг на высоту строки)------
         ButtonDelete.top := ButtonDelete.top + 22;
         //4.3.1.---------------------------------------------------------------

         //4.3.2.Выключение кнопки "Добавление координаты"----------------------
         if n = rows then ButtonAdd.enabled := false;
         //4.3.2.---------------------------------------------------------------

         //4.3.3.Включение/Выключение кнопки "Удаление строк"-------------------
         if n > 1 then begin
            ButtonDraw.enabled := true;
         end
         else ButtonDraw.enabled := false;
         //4.3.3.---------------------------------------------------------------
     end;
     //4.3.---------------------------------------------------------------------

     //4.4.Добавление координат в массив----------------------------------------
     coordinates[n].x := strtoint(xstr);
     coordinates[n].y := strtoint(ystr);
     if n > 3 then begin
               new(betw);
               intersections:=0;
               for i:=1 to n-3 do begin
                   if intersection(coordinates[i],coordinates[i+1],coordinates[n-1],coordinates[n]) then begin
                      intersections:=intersections+1;
                   end;
               end;
               betw^.amount:=intersections;
               betw^.next:=point;
               new(point);
               point:=betw;
     end;
     //4.4.---------------------------------------------------------------------

     //4.5.Добавление координат в таблицу с координатами------------------------
     with stringgrid2 do
	begin
        cells[0, n] := inttostr(n);
        cells[1, n] := xstr;
        cells[2, n] := ystr;
     end;
     //4.5.---------------------------------------------------------------------
end;
//4.----------------------------------------------------------------------------

//5.Удаление строки координаты--------------------------------------------------
procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
     if point<>nil then point:=point^.next;
     //5.1.Удаление строк-------------------------------------------------------
     n := n - 1;
     stringgrid2.RowCount := n + 1;
     //5.1.---------------------------------------------------------------------

     //5.2.Включение/Выключение кнопки "Удаление строк"-------------------------
     if n > 1 then ButtonDraw.enabled:=true
     else ButtonDraw.enabled := false;
     //5.2.---------------------------------------------------------------------

     //5.3.Выключение кнопкок "Удаление строк/Очистка координат"----------------
     if (n < 1) then begin
        ButtonDelete.visible := false;
        ButtonClear.enabled := false;
     end
     //5.3.---------------------------------------------------------------------
     else begin
        //5.4.Визуал для кнопки удаление строки(сдвиг на высоту строки)---------
        ButtonDelete.top := ButtonDelete.top - 22;
        //5.4.------------------------------------------------------------------


        //5.5.Включение кнопкок "Добавление координат"--------------------------
        if n = rows - 1 then begin
           ButtonAdd.enabled := true;
        end;
        //5.5.------------------------------------------------------------------
     end;
end;
//5.----------------------------------------------------------------------------

//6.Очистка координат-----------------------------------------------------------
procedure TForm1.ButtonClearClick(Sender: TObject);
const
     topb = 142;
var
  i:integer;
begin
     Form1.Refresh;
     point:=nil;
     pict:=false;

     CheckBox1Change(Sender);

     //6.1.Выключение кнопки "Очистка координат"--------------------------------
     ButtonDraw.enabled := false;
     //6.1.---------------------------------------------------------------------

     for i := 1 to n do begin
         stringgrid2.cells[0, i] := '';
         stringgrid2.cells[1, i] := '';
         coordinates[i].x := 0;
         coordinates[i].y := 0;
     end;

     n := 0;
     stringgrid2.RowCount := 1;

     with ButtonDelete do
	begin
        top := topb;
        visible := false;
     end;

     ButtonClear.enabled := false;
end;
//6.----------------------------------------------------------------------------

//7.Отрисовка Фигур-------------------------------------------------------------
procedure TForm1.ButtonDrawClick(Sender: TObject);
const
     //7.1.Цвета фигур----------------------------------------------------------
     color1 = clred;
     color2 = clblue;
     //7.1.---------------------------------------------------------------------
var
  i,m:integer;
  interstr:string;
  colorx, colory:^integer;
  first_p, second_p:coord;

//7.2.Заливка фигур-------------------------------------------------------------
procedure colorfill(clr:tcolor; x, y:integer);
     begin
     with form1.Canvas do begin
        Brush.Color := clr;
        FloodFill(x, y, clblack, fsborder);
     end;
end;
//7.2.--------------------------------------------------------------------------

//7.3.Отрисовка Фигуры----------------------------------------------------------
procedure Figure(sign, x, y:integer);
 var i:integer;
     begin
     Canvas.moveto(x + sign * coordinates[1].x, y - sign * coordinates[1].y);

     for i := 2 to n do begin
         Canvas.lineto(x + sign * coordinates[i].x , y - sign * coordinates[i].y);
     end;

     Canvas.lineto(x + sign * coordinates[1].x, y - sign * coordinates[1].y);
end;
//7.3.--------------------------------------------------------------------------
begin
     Form1.Refresh;

     //7.4.Отрисовка Фигур------------------------------------------------------
     Figure(1, xpos1, ypos1);
     Figure(-1, xpos2, ypos2);
     //7.4.---------------------------------------------------------------------

     pict:=true;

     //7.5.Заливка фигуры если точек больше 2-----------------------------------
     if n > 2 then begin
        new(colorx);
        new(colory);
        colorx^:=0;
        colory^:=0;
        colorx^ := colorx^ + coordinates[1].x + (round((coordinates[2].x - coordinates[1].x) / 2));
        colory^ := colory^ + coordinates[1].y + (round((coordinates[2].y - coordinates[1].y) / 2));
        //7.5.1.Нахождение точки для заливки------------------------------------
        if n > 3 then begin
           new(betw);
           intersections:=0;
           for i:=2 to n-2 do begin
               if intersection(coordinates[i], coordinates[i+1], coordinates[1], coordinates[n]) then begin
                      intersections:=intersections+1;
               end;
           end;
           betw^.amount:=intersections;
           betw^.next:=point;
           new(point);
           point:=betw;
        end;
        new(betw);
        betw:=point;
        interstr:='';
        while (betw<>nil) do begin
            if (betw^.amount<>0) then interstr:=interstr+' '+inttostr(betw^.amount);
            betw:=betw^.next;
        end;
        if (interstr<>'') then showmessage('Figure is self-intersecting polygon with '+interstr+' intersections The figure cannot be painted')
        else begin
           intersections:=0;
           if (abs(coordinates[2].x - coordinates[1].x)) > (abs(coordinates[2].y - coordinates[1].y)) then begin
              first_p.x:=colorx^;
              first_p.y:=150;
              second_p.x:=colorx^;
              second_p.y:=colory^;
              for i:=1 to n do begin
                  m:=(i mod n)+ 1;
                  if intersection(first_p, second_p, coordinates[i],coordinates[m]) then begin
                     intersections:=intersections+1;
                  end;
              end;
              if ((intersections mod 2) = 1) then begin
                 repeat
                       colory^:=colory^ - 1;
                       showmessage('-y');
                 until (Canvas.Pixels[colorx^ + xpos1, -colory^+ypos1] <> clblack);
              end
              else begin
                 repeat
                      colory^:=colory^ + 1;
                      showmessage('+y');
                 until (Canvas.Pixels[colorx^ + xpos1, -colory^+ypos1] <> clblack);
              end;
           end
           else begin
               first_p.x:=150;
               first_p.y:=colory^;
               second_p.x:=colorx^;
               second_p.y:=colory^;
               for i:=1 to n do begin
                    m:=(i mod n)+ 1;
                    if intersection(first_p, second_p, coordinates[i],coordinates[m]) then begin
                     intersections:=intersections+1;
                  end;
                end;
               if ((intersections mod 2) = 1) then begin
                   repeat
                        colorx^:=colorx^ - 1;
                        showmessage('-x');
                   until (Canvas.Pixels[colorx^ + xpos1, -colory^+ypos1] <> clblack);
                end
                else begin
                     repeat
                           colorx^:=colorx^ + 1;
                           showmessage('+x');
                     until (Canvas.Pixels[colorx^ + xpos1, -colory^+ypos1] <> clblack);
                end;
           end;
           //7.5.1.------------------------------------------------------------
           //7.5.2.Заливка фигуры----------------------------------------------
           colorx^ := colorx^ + xpos1;
           colory^ := ypos1 - colory^;
           colorfill(color1, colorx^, colory^);
           colorx^ := -1 * (colorx^ - xpos1) + xpos2;
           colory^ := -1 * (colory^ - ypos1) + ypos2;
           colorfill(color2, colorx^, colory^);
           //7.5.2.------------------------------------------------------------
           dispose(colorx);
           dispose(colory);
        end;
     end;
     //7.6.Отрисовка осей-------------------------------------------------------
     CheckBox1Change(Sender);
     //7.6.---------------------------------------------------------------------
     if (n > 3) and (point<>nil) then point:=point^.next;
end;

//8.Отрисовка осей--------------------------------------------------------------
procedure TForm1.CheckBox1Change(Sender: TObject);

//8.1.Отрисовка наконечников линий осей-----------------------------------------
procedure f_arrow(x, y:integer);
begin
     with Canvas do begin
          moveto(x + length - arrow, y + arrow);
          lineto(x + length, y);
          lineto(x + length - arrow, y - arrow);
          moveto(x - arrow, y - length + arrow);
          lineto(x, y - length);
          lineto(x + arrow, y - length + arrow);
     end;
end;
//8.1.--------------------------------------------------------------------------

//8.2.Отрисовка линий осей------------------------------------------------------
procedure axes(x, y:integer);
begin
     with Canvas do begin
          line(x - length, y, x + length, y);
          line(x, y + length, x, y - length);
     end;
end;
//8.2.--------------------------------------------------------------------------

//8.3.Отрисовка обозначений x осей----------------------------------------------
procedure labelx(lbl:tlabel; x, y:integer);
begin
     with lbl do begin
          Top:= y;
          left:= x + length + arrow;
          Visible:=true;
     end;
end;
//8.3.--------------------------------------------------------------------------

//8.4.Отрисовка обозначений y осей----------------------------------------------
procedure labely(lbl:tlabel; x, y:integer);
     begin
     with lbl do begin
        Top:= y - length - arrow;
        left:= x + arrow;
        Visible:=true;
     end;
end;
//8.4.--------------------------------------------------------------------------


begin
     //8.5.Отрисовка осей-------------------------------------------------------
     if Form1.CheckBoxAxes.Checked then begin
        //8.5.1.Стрелки---------------------------------------------------------
        f_arrow(xpos1, ypos1);
        f_arrow(xpos2, ypos2);
        //8.5.1.----------------------------------------------------------------

        //8.5.2.Линии-----------------------------------------------------------
        axes(xpos1, ypos1);
        axes(xpos2, ypos2);
        //8.5.2.----------------------------------------------------------------

        //8.5.3.Обзначения------------------------------------------------------
        labelx(label1, xpos1, ypos1);
        labely(label3, xpos1, ypos1);
        labelx(label2, xpos2, ypos2);
        labely(label4, xpos2, ypos2);
        //8.5.3.----------------------------------------------------------------
     end
     else begin
         //8.5.4.Стирание обзначений--------------------------------------------
         label1.Visible:=false;
         label2.Visible:=false;
         label3.Visible:=false;
         label4.Visible:=false;
         //8.5.4.---------------------------------------------------------------
     end;
     //8.5.---------------------------------------------------------------------
end;
//8.----------------------------------------------------------------------------

//9.Изменение чекбокса отрисовки осей-------------------------------------------
procedure TForm1.CheckBox2Change(Sender: TObject);
begin
     Form1.Refresh;
     if pict then ButtonDrawClick(Sender)
     else CheckBox1Change(Sender);
end;
//9.----------------------------------------------------------------------------

end.
