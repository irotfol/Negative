unit Unit1;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  ComCtrls, StdCtrls, Menus;

const
     //Высота строки
     Row_Heigth = 22;
     //Отступ слева для центра координат
     xpos = 150;
     //Отступ сверху для центра координат
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
    Edit1: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelStartCount: TLabel;
    LabelAuthor: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItemLoadAuthor: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemSaveAuthor: TMenuItem;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure MenuItemLoadAuthorClick(Sender: TObject);
    procedure MenuItemSaveAuthorClick(Sender: TObject);     //1.
    procedure FormCreate(Sender: TObject);                  //2.
    procedure FormWindowStateChange(Sender: TObject);       //3.
    procedure MenuItemExitClick(Sender: TObject);           //4.
    procedure ButtonAddClick(Sender: TObject);              //5.
    procedure ButtonDeleteClick(Sender: TObject);           //6.
    procedure ButtonClearClick(Sender: TObject);            //7.
    procedure ButtonDrawClick(Sender: TObject);             //8.
    procedure CheckBox1Change(Sender: TObject);             //9.

  private
  public
  end;

var
  Form1:TForm1;
  //Массивы для координат
  coordinates_f, coordinates_s:xy;
  //Количество координат
  n:byte;

implementation
{$R *.lfm}
{ TForm1 }

//1.Кнопки меню "Сохранение/загрузка информации об автора"----------------------
procedure TForm1.MenuItemSaveAuthorClick(Sender: TObject);
begin
     memo1.lines.SaveToFile('author_info.txt');
end;

procedure TForm1.MenuItemLoadAuthorClick(Sender: TObject);
begin
     if FileExists('author_info.txt') then
     memo1.lines.LoadFromFile('author_info.txt');
end;
//1.----------------------------------------------------------------------------

//2.При открытии формы----------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
var
  //Файл для хранения количества запусков
  fil:file of word;
  //Число для хранения количества запусков
  launches_count:word;
begin
     //2.1.Заполнение шапки таблиц----------------------------------------------
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
     //2.1.---------------------------------------------------------------------

     //2.2.Считывание количества запусков и запись в Edit1----------------------
     if FileExists('data.dat') then begin
        assignfile(fil, 'data.dat');
        reset(fil);
        read(fil, launches_count);
        edit1.text:=inttostr(launches_count);
        closefile(fil);
     end
     else launches_count:=1;
     //2.2.---------------------------------------------------------------------

     //2.3.Запись количества запусков в файл------------------------------------
     assignfile(fil, 'data.dat');
     launches_count:=launches_count+1;
     rewrite(fil);
     write(fil, launches_count);
     closefile(fil);
     //2.3.---------------------------------------------------------------------

     //2.4.Очистка перменной----------------------------------------------------
     n := 0;
     //2.4.---------------------------------------------------------------------
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

//4.Выход из программы----------------------------------------------------------
procedure TForm1.MenuItemExitClick(Sender: TObject);
begin
     setlength(coordinates_f,0);
     setlength(coordinates_s,0);
     close;
end;
//4.----------------------------------------------------------------------------

//5.Запись кооординат-----------------------------------------------------------
procedure TForm1.ButtonAddClick(Sender: TObject);

//5.1.Проверка введенных координат на пустоту-----------------------------------
function stringtoint(str:string):integer;
begin
     if str = '' then stringtoint:= 0
     else stringtoint:=strtoint(str);
end;
//5.1.--------------------------------------------------------------------------

var
  //Новая координата
  new_coord:^Tpoint;
begin
     //5.1.Ввод новой координаты------------------------------------------------
     new(new_coord);
     new_coord^.X:=stringtoint(stringgrid1.cells[0,1]) + xpos;
     new_coord^.Y:=ypos - stringtoint(stringgrid1.cells[1,1]);
     //5.1.---------------------------------------------------------------------

     //5.2.Проверка координаты--------------------------------------------------
     if (coordinates_f <> nil) and (new_coord^.X = coordinates_f[n].X) and (new_coord^.Y = coordinates_f[n].Y) then begin
        showmessage('Coordinates can not be identical');
        exit;
     end;
     //5.2.---------------------------------------------------------------------

     //5.3.Добавление координаты в массив---------------------------------------
     setlength(coordinates_f, n + 1);
     coordinates_f[n]:= new_coord^;
     new_coord^.X:=-new_coord^.X + 2 * xpos;
     new_coord^.Y:=-new_coord^.Y + 2 * ypos;
     setlength(coordinates_s, n + 1);
     coordinates_s[n]:=new_coord^;
     dispose(new_coord);
     //5.3.---------------------------------------------------------------------

     //5.4.Добавление строки в таблицу2-----------------------------------------
     n:=n + 1;
     stringgrid2.RowCount := n + 1;
     //5.4.---------------------------------------------------------------------

     //5.5.Включение кнопок "Удаление строк/Очистка координат"-----------------
     if n = 1 then begin
        ButtonDelete.visible := true;
        ButtonClear.enabled := true;
     end
     else begin
         //5.5.1.Визуал для кнопки удаление строки(сдвиг на высоту строки)------
         ButtonDelete.top := ButtonDelete.top + Row_Heigth;
         //5.5.1.---------------------------------------------------------------

         //5.5.2.Выключение кнопки "Добавление координаты"----------------------
         if n = rows then ButtonAdd.enabled := false;
         //5.5.2.---------------------------------------------------------------

         //5.5.3.Включение/Выключение кнопки "Удаление строк"-------------------
         if n > 1 then begin
            ButtonDraw.enabled := true;
         end
         else ButtonDraw.enabled := false;
         //5.5.3.---------------------------------------------------------------
     end;
     //5.5.---------------------------------------------------------------------

     //5.6.Добавление координат в таблицу с координатами------------------------
     with stringgrid2 do
	begin
        cells[0, n] := inttostr(n);
        cells[1, n] := stringgrid1.cells[0,1];
        cells[2, n] := stringgrid1.cells[1,1];
     end;
     //5.6.---------------------------------------------------------------------
end;
//5.----------------------------------------------------------------------------

//6.Удаление строки координаты--------------------------------------------------
procedure TForm1.ButtonDeleteClick(Sender: TObject);
begin
     //6.1.Удаление строк-------------------------------------------------------
     stringgrid2.RowCount := n;
     n := n - 1;
     //6.1.---------------------------------------------------------------------

     //6.2.Включение/Выключение кнопки "Удаление строк"-------------------------
     if n > 1 then ButtonDraw.enabled:=true
     else ButtonDraw.enabled := false;
     //6.2.---------------------------------------------------------------------

     //6.3.Выключение кнопок "Удаление строк/Очистка координат"----------------
     if (n < 1) then begin
        ButtonDelete.visible := false;
        ButtonClear.enabled := false;
     end
     //6.3.---------------------------------------------------------------------

     else begin
        //6.4.Визуал для кнопки удаление строки(сдвиг на высоту строки)---------
        ButtonDelete.top := ButtonDelete.top - Row_Heigth;
        //6.4.------------------------------------------------------------------

        //6.5.Включение кнопок "Добавление координат"--------------------------
        if n = rows - 1 then
        ButtonAdd.enabled := true;
        //6.5.------------------------------------------------------------------
     end;
end;
//6.----------------------------------------------------------------------------

//7.Очистка координат-----------------------------------------------------------
procedure TForm1.ButtonClearClick(Sender: TObject);
const
     topb = 142;
var
  i:byte;
begin
     //7.1.Очистка изображений--------------------------------------------------
     Image1.Refresh;
     Image2.Refresh;
     //7.1.---------------------------------------------------------------------

     //7.2.Рисование осей координат---------------------------------------------
     CheckBox1Change(Sender);
     //7.2.---------------------------------------------------------------------

     //7.3.Выключение кнопки "Рисование фигур" и "Очистка координат"------------
     ButtonDraw.enabled := false;
     ButtonClear.enabled := false;
     //7.3.---------------------------------------------------------------------

     //7.4.Скрытие кнопки "Удаление координаты"---------------------------------
     with ButtonDelete do
	begin
        top := topb;
        visible := false;
     end;
     //7.4.---------------------------------------------------------------------

     //7.5.Очистка массивов-----------------------------------------------------
     setlength(coordinates_f,0);
     setlength(coordinates_s,0);
     //7.5.---------------------------------------------------------------------

     //7.6.Очистка таблицы------------------------------------------------------
     for i := 1 to n do begin
         stringgrid2.cells[0, i] := '';
         stringgrid2.cells[1, i] := '';
     end;
     stringgrid2.RowCount := 1;
     //7.6.---------------------------------------------------------------------

     //7.7.Обнуление количества координат---------------------------------------
     n := 0;
     //7.7.---------------------------------------------------------------------
end;
//7.----------------------------------------------------------------------------

//8.Отрисовка Фигур-------------------------------------------------------------
procedure TForm1.ButtonDrawClick(Sender: TObject);
const
     //8.1.Цвета фигур----------------------------------------------------------
     color1 = clred;
     color2 = clblue;
     //8.1.---------------------------------------------------------------------

//8.2.Отрисовка фигуры----------------------------------------------------------
procedure figure(image:timage; clr:tcolor; arr:xy);
     begin
     with image.Canvas do begin
             //Цвет обводки фигуры
             pen.Color:= clblack;

             Brush.Color := clr;
             Polygon(arr, false,0,-1);
     end;
end;
//8.2.--------------------------------------------------------------------------

begin
     //8.3.Очистка изображений--------------------------------------------------
     Image1.Refresh;
     Image2.Refresh;
     //8.3.---------------------------------------------------------------------

     //8.4.Отрисовка Фигур------------------------------------------------------
     Figure(Image1, color1, coordinates_f);
     Figure(Image2, color2, coordinates_s);
     //8.4.---------------------------------------------------------------------

     //8.5.Рисование осей координат---------------------------------------------
     if Form1.CheckBoxAxes.Checked then CheckBox1Change(Sender);
     //8.4.---------------------------------------------------------------------
end;
//8.----------------------------------------------------------------------------

//9.Отрисовка осей--------------------------------------------------------------
procedure TForm1.CheckBox1Change(Sender: TObject);

//9.1.Отрисовка линий осей------------------------------------------------------
procedure axes(image:timage; clr:tcolor; x, y:integer);
begin
     with image.canvas do begin
          pen.color:=clr;
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
//9.1.--------------------------------------------------------------------------

var
  //Показывать ли буквы осей
  vis:boolean;
  //Цвет осей
  colr:tcolor;
begin
     //9.2.Отрисовка осей-------------------------------------------------------
     if Form1.CheckBoxAxes.Checked then begin
        vis:=true;
        colr:=clblack;
     end
     else begin
        vis:=false;
        colr:=clwhite;
     end;
     axes(image1, colr, xpos, ypos);
     axes(image2, colr, xpos, ypos);
     //9.2.---------------------------------------------------------------------

     //9.3.Обзначения-----------------------------------------------------------
     label1.visible:=vis;
     label3.visible:=vis;
     label2.visible:=vis;
     label4.visible:=vis;
     //9.3.---------------------------------------------------------------------
end;
//9.----------------------------------------------------------------------------
end.
