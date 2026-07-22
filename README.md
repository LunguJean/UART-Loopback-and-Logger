# UART-Loopback-and-Logger

# Etapa 1 — UART Loopback (TX + RX)

În această etapă implementați și verificați modulele UART de bază. Scopul este să demonstrați că tot ce trimiteți
din PuTTY vă vine înapoi corect pe același terminal (loopback hardware):
PuTTY → recepție UART → (fără procesare) → transmisie UART → PuTTY

### <ins>Saptamana 3, joi</ins>

# Rezolvare 
Am inceput proiectul prin structurarea componentelor necesare unui Loopback . Astfel am ales 4 module importante:

- timer_input : are rolul unui contor , atunci cand valoarea maxima (FINAL_VALUE) este atinsa acesta se reseteaza si genereaza un semnal de terminare ( DONE )
- baud_rate : genereaza semnalul de sincronizare pentru receptor si transmitator 
  Modificare : am implementat direct timer_input in modulul baud_rate pentru simplitate.
- uart_rx : receptioneaza datele primite, bit cu bit pana la finalizarea acestora 
- uart_tx : trans,ite mai departe datele receptionate

## Modulul baud_rate

Baud_rate genereaza semnalul baud_tick pentru a stabili momentul in care fiecare bit este transmis sau citit. Astfel este calculata valoarea baud_div , factorul 16 reprezentand frecventa de oversampling.

Update: dupa intalnire am realizat ca este o modalitate mult mai usoara de a implementa uart-ul fara a fi nevoie de baud_rate

## Modulul uart_rx

Modulul Uart_rx are rolul de a receptiona bitii transmisi paralel si de a construi octetul transmis. Totul este implementat sub forma unui FSM cu 4 stari.

Pentru implementare am folosit:
- state_reg - memoreaza starea curentaa FSM-ului
- s_reg - counter pentru impulsurile s_tick
- n_reg - numarul de biti receptionati
- b_reg - memoreaza bitii transmisi

In stare IDLE , rx este in starea 1 logic, iar atunci cand sunt receptionati bitii devine 0 si se trece in START.

In starea START, registrul s_reg numara cate impulsuri s-au parcurs din cele 16 ( fiecare bit este impartit in 16 tick-uri ).Dupa 8 impulsuri s_tick, bitul de start este considerat corect si se trece in urmatoarea stare.

In starea DATA, citirea se face la jumatatea tick-urilor fiecarui bit ( pornind de la jumate, fiecare bit este esantionat cu 16 tick-uri unde din nou este prezenta valoarea de tick-ul 8, valoarea reala a bitului ). Valoarea citita este introdusa in registrul b_reg, iar counter-ul n_reg este incrementat.

Dupa parcurgerea celor 8 biti de date si terminarea bitului de stop, automatul trece in starea STOP, unde rx_done_tick este activat pentru un ciclu de ceas.
Octetul transmis este vizibil in rx_dout.

Am realizat o simulare pentru a vedea mai exact functionalitatea:

<img width="955" height="400" alt="image" src="https://github.com/user-attachments/assets/156274ca-652a-4da7-b93a-8f3be1fbd96e" />

## Modulul uart_tx

Asemeni modului uart_rx, uart_tx se ocupa de transmisia octetului/bitilor receptionati.

Pentru implementare am folosit:
- state_reg - memoreaza starea curentaa FSM-ului
- s_reg - counter pentru impulsurile s_tick
- n_reg - numarul de biti receptionati
- b_reg - memoreaza bitii transmisi

Astfel, la activarea semnalul tx_start automatul trece din IDLE in start ,incarca octetul in registrul b_reg si incepe transmisia. Principiul este acelasi, fiecare bit fiind impartit in 16 tick-uri. Dupa finalizarea transmisiei celor 8 biti de date, tx_done_tick este activat pe un singur ciclu de ceas si se revine in IDLE.


Observatii : asemeni modului baud_rate, am gasit o implementare mai logica si mai usoara ce urmeaza sa fie aplicata ulterior.

## Modulul top_loopback 

In top_loopback am realizat conexiunea aferenta dintre baud_rate, uart_rx si uart_tx pentru a putea simula un ciclu intreg de tip loopback. Modulul este parametrizat,folosindu-se frecventa de ceas a sistemului de 100 Mhz si un baud_rate de 9600.



### <ins>Saptamana 3, sambata</ins>

Am inceput realizarea noului modul uart_rx. Asadar, datorita simplitatii o sa reusesc sa scap de modulul baud_rate deoarece o sa lucrez doar cu ciclurile de ceas in care sunt receptionati bitii.
In loc de "tick-uri" o sa am semnale ce stocheaza numarul de impulsuri de ceas ce se parcurg la citirea unui bit de informatie. Am implementat urmatoarele semnale:
- clock_count_ reg - valoarea contorului de ceas
- clock_count_next - valoarea ce v-a fi incarcata in registru in urmatorul front de ceas

Deoarece in continuare este vorba de un modul parametrizat, am ales sa pastrez in continuare parametrii stabiliti de frecventa si baud_rate, ulterior calculand impulsurile de ceas per bit ( CLK_PER_BIT ) si un counter pentru acesta ( COUNT_BITS ).
Modulul de receptie functioneaza dupa urmatoarea regula : 
- in starea "idle" se asteapta receptia datelor
- in starea "start", atunci cand numarul de impulsuri de ceas ajunge la jumatea numarului total de impulsuri pe un bit, se trece la primul bit de date si in starea "data"
- in starea "data" , odata ce se parcurge numarul total de impulsuri de ceas calculat, incepand de la jumatatea bitului de start, se stocheaza valoarea bitului de informatie, acesta fiind cel corect
- in starea "stop", daca se ajunge la numarul de impulsuri de ceas necesar parcurgerii unui bit, automatul revine in starea idle si atribuie un singur impuls de ceas semnalului rx_done ( receptia s-a finalizat )

Am creat si un testbench pentru a putea visualiza informatia receptionata si cele 4 stari ( idle = 0. start = 1, data = 2, stop = 3):
<img width="1574" height="803" alt="image" src="https://github.com/user-attachments/assets/2d03ad9a-ba87-44c7-8caf-59a3c63129f8" />

Deci se observa clar cum bit-ul de start este citit la jumatatea impulsurilor de ceas, mai apoi deplasandu-se cu toate impulsurile pentru a putea decide valoarea fiecarui bit de date.
<img width="1246" height="701" alt="image" src="https://github.com/user-attachments/assets/7872c864-c4f2-4d5f-b7fa-81ae681f635b" />


### <ins>Saptamana 4, luni</ins>

Modulul uart_tx este implementat dupa ceeasi logica ca uart_rx cu modificarile necesare. Astfel, modulul de transmisie functioneaza in felul urmator:

-in starea idle, modulul asteapta tx_start pentru a putea incarca octetul transmis intr-un registru intern. Dupa incarcare, FSM-ul trece in satrea start.

-in starea start, bitul de start este transmis pe durata unui numar de impulsuri de ceas egal cu CLK_PER_BIT, automatul trecand ulterior in starea data

-in starea data, fiecare bit este transmis incepand cu LSB. Dupa parcurgerea unui numar de impulsuri de ceas egal cu CLK_PER_BIT, se pregateste urmatorul bit prin shiftarea la dreapta a registrului de date. Se repeta procesul pana la transmiterea tuturor bitilor

-in starea stop, linia de transmisie este 1 pe durata unui bit de stop. Automatul revine in idle si genereaza un impuls de un singur ciclu de ceas pentru tx_done.


Am realizat si un testbench exclusiv pentru a vizualiza transmiterea bitilor de date. Aici am intampinat probleme in vizualizarea bitilor de date transmisi 
<img width="1464" height="743" alt="image" src="https://github.com/user-attachments/assets/b9a9fcc6-4482-498f-bd12-54038dd28af5" />

In final, modulele uart_rx si uart_tx au fost implementate in modulul top_loopback pentru a definitiva receptia si transmisia prin intermediului FPGA-ului. In aplicatia Putty am configurat comunicatia seriala pentru COM4 ( specific unitatii pe care lucrez) cu o rata de transmisie de 9600 si un singur bit de stop. In urma testarii, caracterele transmise au fost receptionate de FPGA si retransmise catre Putty.


### <ins>Saptamana 4, marti</ins>

Pentru etapa 2 ( "Logger interactiv cu counter binar ") am conceput o schema pentru a intelege mai usor implementarea.

<img width="2048" height="1536" alt="image" src="https://github.com/user-attachments/assets/a7085dab-d676-403f-ad9c-0f5e92b5fa5c" />

Fata de prima parte, unde am avut de implementat doar receptia si transmisia prin intermediul FPGA a unor date prin conceptul de loopback, acum a fost necesar sa implementez prtotocolul complet de comunicatie. Tema implica modificarea unui counter prin intermediul mesajelor primite si a butoanelor, deci sistemul trebuie sa poata interpreta comenzile transmise si sa transmita catre calculator raspunsurile corespunzatoare. Astfel, am ales sa implementez, in plus, urmatoarele module:

- Fifo_rx - memoreaza temporar caracterele receptionate, oprind procesul de receptie pana la procesarea datelor
- command - citeste caracterele din fifo_rx ,identifica tipul comenzii si transmite mai departe semnalul necesar : inc, dec si reset.
- controller - primeste semnalele de la command, precum si cele de la butoane si stabileste daca exista conflicte. Pe baza analizei se genereaza un semnal pentru contor
- Bin_Hex - converteste valoare binara a counter-ului de 16 b in valoare hexazecimala pentru a putea creea mesajul
- message - construieste mesajul ce v-a fi transmis catre calculator ( operatia care a fost facuta + valoarea contorului )
- Fifo_tx - memoreaza temporar caracterele mesajului

Pentru a usura realizarea proiectului, am decis sa implementez partea de receptie a datelor,impreuna cu operatia prin intermediul butoanelor si sa construiesc controller-ul. Ulterior, valoarea contorului v-a fi afisata prin intermediul celor 16 led-uri si a afisajului cu 7 segmente.


### <ins>Saptamana 4, miercuri</ins>

Modulul "command" primeste caracterul transmis prin rx_fifo de la rx_uart.Acesta functioneaza ca un decodor pentru comenzile primite de la calculato de incrementare, decrementare si reset. Astfel, atunci cand controller-ul e gata sa primeasca o comanda, iar rx_fifo are incarcata o valoare primita de la calculator, FSM-ul trece in starea de citire a datelor de la calculator. Dupa "read" urmeaza tranzitia in starea de salvare a caracterelor primite, ulterior fiind decodate corespunzator dupa valorile din tabelul atasat.

Modulul controller reprezinta unitatea centrala de control a intreg circuitului . Acesta primeste informatia atat de la calculator cat si de la butoanele fizice.
Comenzile provenite de la calculator sunt reprezentate de cmd_inc, cmd_dec, cmd_res, cmd_status, cmd_help și cmd_invalid,generate de modulul "command". In paralel se primesc comenzi de la butoanele fizice (inc_valid, dec_valid, reset_valid, semnale trecute prin sincronizator, debouncer, timer, edge detector si priority). Astfel, am stabilit o lista de prioritati pentru evitarea conflictelor:
-cmd_res sau reset_valid - comanda de reset
-cmd_inc - incrementarea prin UART
-cmd_dec - decrementarea prin UART 
-inc_valid - incrementarea prin buton 
-dec_valid - decrementarea prin buton 
-cmd_status - afisarea starii contorului
-cmd_help - afisarea mesajului de ajutor
-cmd_invalid - tratarea comenzilor invalide


Comenzile provenite de la calculator sunt reprezentate prin semnalele cmd_inc, cmd_dec, cmd_res, cmd_status, cmd_help și cmd_invalid, generate de modulul Command Parser după interpretarea caracterelor primite prin UART. În paralel, comenzile provenite de la butoanele fizice sunt reprezentate prin semnalele inc_valid, dec_valid și reset_valid, obținute după sincronizarea, eliminarea fenomenului de bouncing și detectarea frontului de apăsare.

Modulul b2h(Bin_Hex) realizeaza conversia din binar in zecimal, impartind cei 16 biti ai contorului in grupe de cate 4.

Modulul Message functioneaza ca un generator de mesaje. Acesta primeste de la controller tipul evenimentului ( inc, dec, reset, afisarea valorii contorului , help sau comanda invalida ), construieste mesajul text si transmite caracter cu caracter catre tx_fifo.

<ins>Transformarea in ASCII</ins>

Pentru a putea transmite informatia din nou catre calculator prin uart_tx, valoarea primita prin b2h catre message trebuie transformata in cod ASCII. Pentru acest lucru am deci sa b2h sa faca doar impartirea celor 16 biti si in message sa implementez transformarea.

Conversia se realizeaza astfel:
- daca cifra este intre 0-9, se adauga valoarea 0x30 deoarece '0' in ascii este 0x30. Acest lucru face ca '1' sa fie 0x31, etc.
- daca cifra este intre 10-15 ( A si F ), se adauga 0x41 ( A )  si se scade 10. Practic, '11' este 0x42, etc.

Am realizat si o simulare pentru a fi sigur ca transformarea functioneaza:
<img width="1583" height="805" alt="image" src="https://github.com/user-attachments/assets/f4d2f076-d3cd-4daf-9270-0a090227fff2" />

Mai departe, pentru a incheia transmisia, mesajele construite sunt receptionate de tx_fifo, unde sunt memorate temporar, caracter cu caracter.

Ulterior,tx_fifo transmite lui tx_controller,modul ce controleaza transmisia prin interfata UART. In momentul in care tx_fifo nu este gol, tx_controller activeaza semnalul de citire, preia caracterul si il memoreaza intr-un registru intern. In continuare, controller-ul trimite un semnal de un singur ciclu de ceas uart_tx_start si caracterul memorat este transmis prin bus-ul uart_tx_data catre uart_tx. Dupa terminarea transmisiei, controller-ul asteapta uart_tx_done pentru a putea trece la urmatorul caracter din tx_fifo.

In final, modulul uart_tx realizeaza transmisia, datele fiind trimise prin tx_pin si receptionate de Putty in configuratie seriala.




  


