unit Unit1;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  ComCtrls, StdCtrls, Menus;

const
     //Высота строки
     Row_Heigth = 22;
     //Отступ слева для первого центра координат
     xpos = 150;
     //Отступ сверху для первого центра координат
     ypos = 150;
     //Длина стрелок у координат
     arrow = 10;
     //Расстояние от центра координат до краев координатной плоскости
     length = 150;
     //Максимальное количество координат
     rows = 14;

type

  { TForm1 }

  xy = Array of Tpoint;
  TForm1 = class(TForm)
    ButtonAdd: TButton;
    ButtonDelete: TButton;
    ButtonClear: TButton;
    ButtonDraw: TButton;
    CheckBoxAxes: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelStartCount: TLabel;
    LabelAuthor: TLabel;
    MainMenu1: TMainMenu;
    MenuItemFile: TMenuItem;
    MenuItemSaveAuthor: TMenuItem;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonDrawClick(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure MenuItemSaveAuthorClick(Sender: TObject);

  private
  public
  end;

var
  Form1:TForm1;
  coordinates_f, coordinates_s:xy;
  //Количество координат
  n:integer;
  //Нарисованы ли фигуры
  pict:boolean;
  //Файл для хранения автора
  authorfile:text;
  //Строка для хранения автора
  author:^string;

implementation
{$R *.lfm}
{ TForm1 }

//1.Кнопка меню "Сохранение автора"---------------------------------------------
procedure TForm1.MenuItemSaveAuthorClick(Sender: TObject);
begin
     assignfile(authorfile, 'Author.txt');
     new(author);
     author^:=Inputbox('Author', 'Enter author','');
     rewrite(authorfile);
     write(authorfile, author^);
     form1.labelauthor.Caption:='Автор: ' + author^;
     dispose(author);
     closefile(authorfile);
end;
//1.----------------------------------------------------------------------------

//2.При открытии формы----------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
var
  //Файл для хранения количества запусков
  fil:file of word;
  //Число для хранения количества запусков
  tr:^word;
begin
     //2.1.Очистка перменных/массива--------------------------------------------
     n := 0;
     pict:=false;
     setlength(coordinates_f, n);
     //2.1.---------------------------------------------------------------------

     //2.2.Считывание количества запусков---------------------------------------
     assignfile(fil, 'data.dat');
     if FileExists('data.dat') then begin
        reset(fil);
        new(tr);
        read(fil, tr^);
        closefile(fil);
     end;
     //2.2.---------------------------------------------------------------------

     //2.3.Запись количества запусков в файл------------------------------------
     assignfile(fil, 'data.dat');
     tr^:=tr^+1;
     rewrite(fil);
     write(fil, tr^);
     form1.Labelstartcount.Caption:='Количество запусков программы: ' + inttostr(tr^);
     dispose(tr);
     closefile(fil);
     //2.3.---------------------------------------------------------------------

     //2.4.Считывание автора из файла-------------------------------------------
     assignfile(authorfile, 'Author.txt');
     if FileExists('author.txt') then begin
        reset(authorfile);
        new(author);
        read(authorfile, author^);
        form1.Labelauthor.Caption:='Автор: ' + author^;
        dispose(author);
        closefile(authorfile);
     end;
     //2.4----------------------------------------------------------------------

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

//6.Запись кооординат-----------------------------------------------------------
procedure TForm1.ButtonAddClick(Sender: TObject);

function stringtoint(str:string):integer;
begin
     if str = '' then stringtoint:= 0
     else stringtoint:=strtoint(str);
end;
var
  new_coord:^Tpoint;
begin
     //6.1.Проверка координаты--------------------------------------------------
     new(new_coord);
     new_coord^.X:=stringtoint(stringgrid1.cells[0,1]) + xpos;
     new_coord^.Y:=stringtoint(stringgrid1.cells[1,1]) + ypos;
     if (coordinates_f <> nil) then begin
        if (new_coord^.X = coordinates_f[n].X) and (new_coord^.Y = coordinates_f[n].Y) then begin
           showmessage('Coordinates can not be identical');
           exit;
        end;
     end;
     //6.1.---------------------------------------------------------------------

     //6.2.Добавление координаты в массив-----------------------------------------
     setlength(coordinates_f, n + 1);
     coordinates_f[n]:= new_coord^;
     new_coord^.X:=-new_coord^.X + 2 * xpos;
     new_coord^.Y:=-new_coord^.Y + 2 * ypos;
     setlength(coordinates_s, n + 1);
     coordinates_s[n]:=new_coord^;
     dispose(new_coord);
     n:=n + 1;
     //6.2.---------------------------------------------------------------------

     //6.3.Добавление строк-----------------------------------------------------
     stringgrid2.RowCount := n + 1;
     //6.3.---------------------------------------------------------------------

     //6.4.Включение кнопкок "Удаление строк/Очистка координат"-----------------
     if n = 1 then begin
        ButtonDelete.visible := true;
        ButtonClear.enabled := true;
     end
     else begin
         //6.4.1.Визуал для кнопки удаление строки(сдвиг на высоту строки)------
         ButtonDelete.top := ButtonDelete.top + Row_Heigth;
         //6.4.1.---------------------------------------------------------------

         //6.4.2.Выключение кнопки "Добавление координаты"----------------------
         if n = rows then ButtonAdd.enabled := false;
         //6.4.2.---------------------------------------------------------------

         //6.4.3.Включение/Выключение кнопки "Удаление строк"-------------------
         if n > 1 then begin
            ButtonDraw.enabled := true;
         end
         else ButtonDraw.enabled := false;
         //6.4.3.---------------------------------------------------------------
     end;
     //6.4.---------------------------------------------------------------------

     //6.5.Добавление координат в таблицу с координатами------------------------
     with stringgrid2 do
	begin
        cells[0, n] := inttostr(n);
        cells[1, n] := stringgrid1.cells[0,1];
        cells[2, n] := stringgrid1.cells[1,1];
     end;
     //6.5.---------------------------------------------------------------------
end;
//6.----------------------------------------------------------------------------

//7.Удаление строки координаты--------------------------------------------------
procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
     //7.1.Удаление строк-------------------------------------------------------
     stringgrid2.RowCount := n;
     n := n - 1;
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
        ButtonDelete.top := ButtonDelete.top - Row_Heigth;
        //7.4.------------------------------------------------------------------

        //7.5.Включение кнопкок "Добавление координат"--------------------------
        if n = rows - 1 then
        ButtonAdd.enabled := true;
        //7.5.------------------------------------------------------------------
     end;
end;
//7.----------------------------------------------------------------------------

//8.Очистка координат-----------------------------------------------------------
procedure TForm1.ButtonClearClick(Sender: TObject);
const
     topb = 142;
var
  i:byte;
begin
     Form1.Refresh;
     pict:=false;
     setlength(coordinates_f,0);
     setlength(coordinates_s,0);
     CheckBox1Change(Sender);

     //8.1.Выключение кнопки "Очистка координат"--------------------------------
     ButtonDraw.enabled := false;
     //8.1.---------------------------------------------------------------------

     for i := 1 to n do begin
         stringgrid2.cells[0, i] := '';
         stringgrid2.cells[1, i] := '';
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

//9.2.Отрисовка фигуры----------------------------------------------------------
procedure figure(image:timage; clr:tcolor; arr:xy);
     begin
     with image.Canvas do begin
        Brush.Color := clr;
        Polygon(arr, false,0,-1);
     end;
end;
//9.2.--------------------------------------------------------------------------


//9.3.--------------------------------------------------------------------------
begin
     //9.4.Отрисовка Фигур------------------------------------------------------
     Figure(Image1, color1, coordinates_f);
     Figure(Image2, color2, coordinates_s);
     //9.4.---------------------------------------------------------------------
     pict:=true;
     CheckBox1Change(Sender);
end;
//9.----------------------------------------------------------------------------

//10.Отрисовка осей-------------------------------------------------------------
procedure TForm1.CheckBox1Change(Sender: TObject);

//10.2.Отрисовка линий осей-----------------------------------------------------
procedure axes(image:timage; clr:color; x, y:integer);
begin
     with image.canvas do begin
          Brush.color:=clr;
          line(x - length, y, x + length, y);
          line(x, y + length, x, y - length);
          moveto(x + length - arrow, y + arrow);
          lineto(x + length, y);
          lineto(x + length - arrow, y - arrow);
          moveto(x - arrow, y - length + arrow);
          lineto(x, y - length);
          lineto(x + arrow, y - length + arrow);
     end;
end;
//10.2.-------------------------------------------------------------------------

var
  vis:boolean;
  colr:color;
begin
     //10.5.Отрисовка осей------------------------------------------------------
     if Form1.CheckBoxAxes.Checked then begin
        vis:=true;
        colr:=clblack;
     end
     else begin
        vis:=false;
        colr:=clwhite;
     end;
     //10.5.3.Обзначения-----------------------------------------------------
     label1.visible:=vis;
     label3.visible:=vis;
     label2.visible:=vis;
     label4.visible:=vis;
     //10.5.3.---------------------------------------------------------------

     //10.5.2.Оси------------------------------------------------------------
     axes(image1, xpos, ypos);
     axes(image2, xpos, ypos);
     //10.5.2.---------------------------------------------------------------
     //10.5.--------------------------------------------------------------------

end;
//10.---------------------------------------------------------------------------

//11.Изменение чекбокса отрисовки осей------------------------------------------
procedure TForm1.CheckBox2Change(Sender: TObject);
begin
     if pict then begin
        Form1.Refresh;
        ButtonDrawClick(Sender);
     end
     else CheckBox1Change(Sender);
end;
//11.---------------------------------------------------------------------------

end.
