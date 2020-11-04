//
// Этот файл - корень проекта. По сути, это просто оболочка для адаптации терминального модуля к конкретной используемой плате.
//
module terminal
(
   input    clk50,      // тактовая частота 50МГц
   input    resetbtn,   // кнопка сброса, необязательна       

	// консольный UART 
   output   uart_tx,
   input    uart_rx,
	
	// VGA
	output   vgah,         // строчный синхросигнал
   output   vgav,         // кадровый синхросигнал
   output   [4:0] vgar,   // шина DAC красного видеосигнала
   output   [5:0] vgag,   // шина DAC зеленого видеосигнала
   output   [4:0] vgab,   // шина DAC синего видеосигнала

	// управление звуком
	output   buzzer,
	
   // PS/2
   input    ps2_clk, 
   input    ps2_data

);

wire reset;

wire terminal_tx;
wire terminal_rx;
wire sound;

wire autoreset;
reg [5:0]resetcnt;

assign reset=~resetbtn | autoreset;  // сброс от кнопки и стартового таймера
assign buzzer=~sound;                // выход управления звуком платы - инверсный (0-есть звук, 1-нет)
// линии UART, идут на выход платы без преобразования
assign uart_tx=terminal_tx;          
assign terminal_rx=uart_rx;

// цветовые выходы VGA 
wire vgared,vgagreen,vgablue;

// Этот вариант для случая, если на плате стоит несколькобитный DAC для управления яркостью пикселей
// В этом случае - это входые шины DAC  шириной в несколько бит
// выбор яркости каждого цвета, в данном случае - максимальная яркость
assign vgag = (vgagreen == 1'b1) ? 6'b111111 : 6'b000000 ;
assign vgab = (vgablue == 1'b1) ? 5'b11111 : 5'b00000 ;
assign vgar = (vgared == 1'b1) ? 5'b11111 : 5'b00000 ;

// А этот вариант для упрощенного подключения цветовых входов без DAC прямо к выходным пинам FPGA
// В этом случае цветовые линии vga{r,g,b}  - это просто провода, идущие от ножек платы к 
// разъему VGA через небольшой резистор (около 300 Ом).
//assign vgag = vgagreen;
//assign vgab = vgablue;
//assign vgar = vgared;

//**********************************
//*  Генерация начального сброса
//**********************************
assign autoreset= ~(&resetcnt);  // сигнал сброса снимается после того, 
                                 // как таймер досчитает до потолка
initial resetcnt=6'b000000;

always @ (posedge clk50) 
  if (resetcnt != 6'b111111)   // после достижения потолка таймер останавливается
     resetcnt <= resetcnt + 1'b1; 

//**********************************
//*   Терминал VT52
//**********************************
vt52 terminal(
   .vgahs(vgah),           // строчный синхросигнал
   .vgavs(vgav),           // кадровый синхросигнал
	.vgared(vgared),        // красный цвет
	.vgagreen(vgagreen),    // зеленый цвет
	.vgablue(vgablue),      // синий цвет
   .tx(terminal_tx),       // передатчик UART
   .rx(terminal_rx),       // приемник UART
   .ps2_clk(ps2_clk),      // синхросигнал PS/2
   .ps2_data(ps2_data),    // данные PS/2
	.buzzer(sound),         // разрешение звукового сигнала
   .clk50(clk50),          // тактовый сигнал 50МГц
   .reset(reset)           // сброс терминала
);
	  
endmodule