# UART-Loopback-and-Logger

# Etapa 1 — UART Loopback (TX + RX)

În această etapă implementați și verificați modulele UART de bază. Scopul este să demonstrați că tot ce trimiteți
din PuTTY vă vine înapoi corect pe același terminal (loopback hardware):
PuTTY → recepție UART → (fără procesare) → transmisie UART → PuTTY

### <u>Saptamana 3, joi</u>

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


