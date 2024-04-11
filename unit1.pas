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
  //Количество координат
  n:integer;
  //Нарисованы ли фигуры
  pict:boolean;
  //Количество пересечений сторон
  intersections:byte;
  //Массив для хранения координат
  coordinates:xy;
  //Файл для хранения автора
  authorfile:text;
  //Строка для хранения автора
  author:string;
  //Стек для хранения пересечений
  point,betw:zveno;

implementation
{$R *.lfm}
{ TForm1 }

//1.Кнопка меню "Сохранение автора"---------------------------------------------
procedure TForm1.MenuItem2Click(Sender: TObject);
begin
     assignfile(authorfile, 'Author.txt');
     author:=Inputbox('Author', 'Enter author','');
     rewrite(authorfile);
     write(authorfile, author);
     closefile(authorfile);
     form1.labelauthor.Caption:='Автор: ' + author;
end;
//1.----------------------------------------------------------------------------

//2.При открытии формы----------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
var
  //Файл для хранения количества запусков
  fil:file of word;
  //Число для хранения количества запусков
  tr:word;
begin
     //2.1.Очистка перменных/стека----------------------------------------------
     author:='';
     tr:=0;
     pict:=false;
     new(point);
     point:=nil;
     n := 0;
     //2.1.---------------------------------------------------------------------

     //2.2.Считывание количества запусков---------------------------------------
     assignfile(fil, 'data.dat');
     if FileExists('data.dat') then begin
        reset(fil);
        read(fil, tr);
        closefile(fil);
     end;
     //2.2.---------------------------------------------------------------------

     //2.3.Запись количества запусков в файл------------------------------------
     assignfile(fil, 'data.dat');
     tr:=tr+1;
     rewrite(fil);
     write(fil, tr);
     closefile(fil);
     //2.3.---------------------------------------------------------------------

     form1.Labelstartcount.Caption:='Количество запусков программы: ' + inttostr(tr);

     //2.4.Считывание автора из файла-------------------------------------------
     assignfile(authorfile, 'Author.txt');
     if FileExists('author.txt') then begin
        reset(authorfile);
        read(authorfile, author);
        closefile(authorfile);
     end;
     //2.4----------------------------------------------------------------------

     form1.Labelauthor.Caption:='Автор: ' + author;

     //2.5.Заполнение шапки таблиц----------------------------------------------
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
     //2.5.---------------------------------------------------------------------
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
procedure TForm1.ButtonAddClick2(Sender: TObject);
var
  x,y:^string;
begin
     new(x);
     new(y);
     x^:=stringgrid1.cells[0,1];
     y^:=stringgrid1.cells[1,1];

     //4.1.Проверка координат---------------------------------------------------
     if x^ = '' then  x^ := '0';
     if y^ = '' then  y^ := '0';
     if not ((n > 0) and (strtoint(x^) = coordinates[n].x) and (strtoint(y^) = coordinates[n].y)) then ButtonAddClick(x^, y^, Sender)
     else showmessage('Coordinates can not be identical');
     //4.1.--------------------------------------------------------------------------

     dispose(x);
     dispose(y);
end;
//4.----------------------------------------------------------------------------

//5.Проверка двух сторон на пересечения-----------------------------------------
function intersection(cor1,cor2,cor3,cor4:coord):boolean;
var
  p:array [0..3] of integer;
begin
     p[0]:=(cor4.y - cor3.y)*(cor4.x - cor1.x)-(cor4.x - cor3.x)*(cor4.y - cor1.y);
     p[1]:=(cor4.y - cor3.y)*(cor4.x - cor2.x)-(cor4.x - cor3.x)*(cor4.y - cor2.y);
     p[2]:=(cor2.y - cor1.y)*(cor2.x - cor3.x)-(cor2.x - cor1.x)*(cor2.y - cor3.y);
     p[3]:=(cor2.y - cor1.y)*(cor2.x - cor4.x)-(cor2.x - cor1.x)*(cor2.y - cor4.y);
     if (p[0]*p[1]<=0) and (p[2]*p[3]<=0) then
     intersection:=true
     else intersection:=false;
end;
//5.----------------------------------------------------------------------------

//6.Запись кооординат-----------------------------------------------------------
procedure TForm1.ButtonAddClick(xstr,ystr:string; Sender: TObject);
var
  //Счётчик цикла
  i:integer;
begin
     //6.1.Добавление строк-----------------------------------------------------
     n := n + 1;
     stringgrid2.RowCount := n + 1;
     //6.1.---------------------------------------------------------------------

     //6.2.Включение кнопкок "Удаление строк/Очистка координат"-----------------
     if n = 1 then begin
        ButtonDelete.visible := true;
        ButtonClear.enabled := true;
     end
     else begin
         //6.3.1.Визуал для кнопки удаление строки(сдвиг на высоту строки)------
         ButtonDelete.top := ButtonDelete.top + 22;
         //6.3.1.---------------------------------------------------------------

         //6.3.2.Выключение кнопки "Добавление координаты"----------------------
         if n = rows then ButtonAdd.enabled := false;
         //6.3.2.---------------------------------------------------------------

         //6.3.3.Включение/Выключение кнопки "Удаление строк"-------------------
         if n > 1 then begin
            ButtonDraw.enabled := true;
         end
         else ButtonDraw.enabled := false;
         //6.3.3.---------------------------------------------------------------
     end;
     //6.3.---------------------------------------------------------------------

     //6.4.Добавление координат в массив----------------------------------------
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
     //6.4.---------------------------------------------------------------------

     //6.5.Добавление координат в таблицу с координатами------------------------
     with stringgrid2 do
	begin
        cells[0, n] := inttostr(n);
        cells[1, n] := xstr;
        cells[2, n] := ystr;
     end;
     //6.5.---------------------------------------------------------------------
end;
//6.----------------------------------------------------------------------------

//7.Удаление строки координаты--------------------------------------------------
procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
     if point<>nil then point:=point^.next;
     //7.1.Удаление строк-------------------------------------------------------
     n := n - 1;
     stringgrid2.RowCount := n + 1;
     //7.1.---------------------------------------------------------------------

     //7.2.Включение/Выключение кнопки "Удаление строк"-------------------------
     if n > 1 then ButtonDraw.enabled:=true
     else ButtonDraw.enabled := false;
     //7.2.---------------------------------------------------------------------

     //7.3.Выключение кнопкок "Удаление строк/Очистка координат"----------------
     if (n < 1) then begin
        ButtonDelete.visible := false;
        ButtonClear.enabled := false;
     end
     //7.3.---------------------------------------------------------------------
     else begin
        //7.4.Визуал для кнопки удаление строки(сдвиг на высоту строки)---------
        ButtonDelete.top := ButtonDelete.top - 22;
        //7.4.------------------------------------------------------------------

        //7.5.Включение кнопкок "Добавление координат"--------------------------
        if n = rows - 1 then begin
           ButtonAdd.enabled := true;
        end;
        //7.5.------------------------------------------------------------------
     end;
end;
//7.----------------------------------------------------------------------------

//8.Очистка координат-----------------------------------------------------------
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

     //8.1.Выключение кнопки "Очистка координат"--------------------------------
     ButtonDraw.enabled := false;
     //8.1.---------------------------------------------------------------------

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
//8.----------------------------------------------------------------------------

//9.Отрисовка Фигур-------------------------------------------------------------
procedure TForm1.ButtonDrawClick(Sender: TObject);
const
     //9.1.Цвета фигур----------------------------------------------------------
     color1 = clred;
     color2 = clblue;
     //9.1.---------------------------------------------------------------------
var
  i,m:integer;
  interstr:string;
  color_cord:^coord;
  first_p:coord;

//9.2.Заливка фигур-------------------------------------------------------------
procedure colorfill(clr:tcolor; x, y:integer);
     begin
     with form1.Canvas do begin
        Brush.Color := clr;
        FloodFill(x, y, clblack, fsborder);
     end;
end;
//9.2.--------------------------------------------------------------------------

//9.3.Отрисовка Фигуры----------------------------------------------------------
procedure Figure(sign, x, y:integer);
 var i:integer;
     begin
     Canvas.moveto(x + sign * coordinates[1].x, y - sign * coordinates[1].y);

     for i := 2 to n do begin
         Canvas.lineto(x + sign * coordinates[i].x , y - sign * coordinates[i].y);
     end;

     Canvas.lineto(x + sign * coordinates[1].x, y - sign * coordinates[1].y);
end;
//9.3.--------------------------------------------------------------------------
function CenterLine(coor1,coor2:coord):coord;
begin
     CenterLine.x:=coor1.x + (round((coor2.x - coor1.x) / 2));
     CenterLine.y:=coor1.y + (round((coor2.y - coor1.y) / 2));
end;

begin
     Form1.Refresh;

     //9.4.Отрисовка Фигур------------------------------------------------------
     Figure(1, xpos1, ypos1);
     Figure(-1, xpos2, ypos2);
     //9.4.---------------------------------------------------------------------

     pict:=true;

     //9.5.Заливка фигуры если точек больше 2-----------------------------------
     if n > 2 then begin

        //9.5.1.Определение количества пересечений------------------------------
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
        //9.5.1.----------------------------------------------------------------

        new(betw);
        betw:=point;
        interstr:='';
        while (betw<>nil) do begin
            if (betw^.amount<>0) then interstr:=interstr+' '+inttostr(betw^.amount);
            betw:=betw^.next;
        end;

        //9.5.2.Определение точки заливки фигуры--------------------------------
        if (interstr<>'') then showmessage('Figure is self-intersecting polygon with '+interstr+' intersections The figure cannot be painted')
        else begin
           new(color_cord);
           color_cord^.x:=0;
           color_cord^.y:=0;
           first_p.y:=length;
           for i:=0 to n - 1 do begin
               color_cord^:=CenterLine(CenterLine(coordinates[i+1], coordinates[((i+1) mod n)+1]), CenterLine(coordinates[((i+1) mod n) + 1], coordinates[((i+2) mod n) + 1]));
               first_p.x:=color_cord^.x;
               intersections:=0;
               for m:=0 to n-1 do
               begin
                    if intersection(first_p, color_cord^, coordinates[m+1], coordinates[((m+1) mod n) + 1 ]) then intersections:=intersections+1;
               end;
               if intersections mod 2 = 1 then break;
           end;
           //9.5.2.-------------------------------------------------------------

           //9.5.3.Заливка фигуры-----------------------------------------------
           color_cord^.x := color_cord^.x + xpos1;
           color_cord^.y := ypos1 - color_cord^.y;
           colorfill(color1, color_cord^.x, color_cord^.y);
           color_cord^.x := -1 * (color_cord^.x - xpos1) + xpos2;
           color_cord^.y := -1 * (color_cord^.y - ypos1) + ypos2;
           colorfill(color2, color_cord^.x, color_cord^.y);
           dispose(color_cord);
        end;
     end;
     //9.5.3.-------------------------------------------------------------------
     CheckBox1Change(Sender);
     if (n > 3) and (point<>nil) then point:=point^.next;
end;
//9.----------------------------------------------------------------------------

//10.Отрисовка осей-------------------------------------------------------------
procedure TForm1.CheckBox1Change(Sender: TObject);

//10.1.Отрисовка наконечников линий осей----------------------------------------
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
//10.1.-------------------------------------------------------------------------

//10.2.Отрисовка линий осей-----------------------------------------------------
procedure axes(x, y:integer);
begin
     with Canvas do begin
          line(x - length, y, x + length, y);
          line(x, y + length, x, y - length);
     end;
end;
//10.2.-------------------------------------------------------------------------

//10.3.Отрисовка обозначений x осей---------------------------------------------
procedure labelx(lbl:tlabel; x, y:integer);
begin
     with lbl do begin
          Top:= y;
          left:= x + length + arrow;
          Visible:=true;
     end;
end;
//10.3.-------------------------------------------------------------------------

//10.4.Отрисовка обозначений y осей---------------------------------------------
procedure labely(lbl:tlabel; x, y:integer);
     begin
     with lbl do begin
        Top:= y - length - arrow;
        left:= x + arrow;
        Visible:=true;
     end;
end;
//10.4.-------------------------------------------------------------------------


begin
     //10.5.Отрисовка осей------------------------------------------------------
     if Form1.CheckBoxAxes.Checked then begin

        //10.5.1.Стрелки--------------------------------------------------------
        f_arrow(xpos1, ypos1);
        f_arrow(xpos2, ypos2);
        //10.5.1.---------------------------------------------------------------

        //10.5.2.Линии----------------------------------------------------------
        axes(xpos1, ypos1);
        axes(xpos2, ypos2);
        //10.5.2.---------------------------------------------------------------

        //10.5.3.Обзначения-----------------------------------------------------
        labelx(label1, xpos1, ypos1);
        labely(label3, xpos1, ypos1);
        labelx(label2, xpos2, ypos2);
        labely(label4, xpos2, ypos2);
        //10.5.3.---------------------------------------------------------------

     end
     else begin

        //10.5.4.Стирание обзначений-------------------------------------------
         label1.Visible:=false;
         label2.Visible:=false;
         label3.Visible:=false;
         label4.Visible:=false;
         //10.5.4.--------------------------------------------------------------

     end;
     //10.5.--------------------------------------------------------------------

end;
//10.---------------------------------------------------------------------------

//11.Изменение чекбокса отрисовки осей------------------------------------------
procedure TForm1.CheckBox2Change(Sender: TObject);
begin
     Form1.Refresh;
     if pict then ButtonDrawClick(Sender)
     else CheckBox1Change(Sender);
end;
//11.---------------------------------------------------------------------------

end.
