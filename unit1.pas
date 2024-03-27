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
    x:integer;
    y:integer;
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
    Label5: TLabel;
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
  n:integer;
  pict:boolean;
  coordinates:xy;

implementation

{$R *.lfm}

{ TForm1 }

//Сохранение автора-------------------------------------------------------------
procedure TForm1.MenuItem2Click(Sender: TObject);
var
  authorfile:text;
  author:string;
begin
  assignfile(authorfile, 'Author.txt');
  author:=Inputbox('Author', 'Enter author','');
  rewrite(authorfile);
  write(authorfile, author);
  closefile(authorfile);
end;
//------------------------------------------------------------------------------

procedure TForm1.FormCreate(Sender: TObject);
var
  fil:text;
  tr:integer;
begin
     pict:=false;
     tr:=0;
     n := 0;
//1.Сохранение количества запусков----------------------------------------------
     assignfile(fil, 'data.txt');

     if FileExists('data.txt') then begin
        reset(fil);
        while not eof(fil) do begin
              read(fil, tr);
        end;
        closefile(fil);
     end;

     assignfile(fil, 'data.txt');
     tr:=tr+1;
     rewrite(fil);
     write(fil, tr);
     closefile(fil);
     form1.Label5.Caption:='Количество запусков программы: ' + inttostr(tr);
//1.----------------------------------------------------------------------------

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

procedure TForm1.ButtonAddClick(xstr,ystr:string; Sender: TObject);
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
         if n > 1 then ButtonDraw.enabled := true
         else ButtonDraw.enabled := false;
         //4.3.3.---------------------------------------------------------------
     end;
     //4.3.---------------------------------------------------------------------

     //4.4.Добавление координат в массив----------------------------------------
     coordinates[n].x := strtoint(xstr);
     coordinates[n].y := strtoint(ystr);
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
  i:integer;
  colorx, colory:^integer;

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

        colorx^ := xpos1;
        colory^ := ypos1;
        colorx^ := colorx^ + coordinates[1].x + ((coordinates[2].x - coordinates[1].x) div 2);
        colory^ := colory^ - coordinates[1].y - ((coordinates[2].y - coordinates[1].y) div 2);

        //7.5.1.Нахождение точки для заливки------------------------------------
        if (abs(coordinates[2].x - coordinates[1].x) > abs(coordinates[2].y - coordinates[1].y)) then begin
           for i := 1 to colory^ + 150 do begin
               If (Canvas.Pixels[colorx^, i] = clblack) and (Canvas.Pixels[colorx^, i + 1] <> clblack) then begin
                  colory^ := i + 1;
                  break;
               end;
            end;
        end
        else begin
             for i := 1000 downto colorx^ - 150 do begin
                If (Canvas.Pixels[i, colory^] = clblack) and (Canvas.Pixels[i - 1, colory^] <> clblack) then begin
                   colorx^ := i - 1;
                   break;
                end;
            end;
        end;
        //7.5.1.----------------------------------------------------------------

        //7.5.2.Заливка фигуры--------------------------------------------------
        colorfill(color1, colorx^, colory^);
        colorx^ := -1 * (colorx^ - xpos1) + xpos2;
        colory^ := -1 * (colory^ - ypos1) + ypos2;
        colorfill(color2, colorx^, colory^);
        //7.5.2.----------------------------------------------------------------

        dispose(colorx);
        dispose(colory);
     end;
     //7.6.Отрисовка осей-------------------------------------------------------
     CheckBox1Change(Sender);
     //7.6.---------------------------------------------------------------------
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
