# UART-Loopback-and-Logger

# Etapa 1 — UART Loopback (TX + RX)

În această etapă implementați și verificați modulele UART de bază. Scopul este să demonstrați că tot ce trimiteți
din PuTTY vă vine înapoi corect pe același terminal (loopback hardware):
PuTTY → recepție UART → (fără procesare) → transmisie UART → PuTTY


# Rezolvare 
Am inceput proiectul prin structurarea componentelor necesare unui Loopback . Astfel am ales 4 module importante:

- timer_input : are rolul unui contor , atunci cand valoarea maxima (FINAL_VALUE) este atinsa acesta se reseteaza si genereaza un semnal de terminare ( DONE )
- baud_rate : genereaza semnalul de sincronizare pentru receptor si transmitator ( un bit este impartit in 16 tick-uri pentru a evita oversamplingul, iar atunci cand baud_tick / done este 1 transmite valoarea catre componentele de transmisiune ale uartului )
- uart_rx : receptioneaza datele primite, octet cu octet pana la finalizarea acestora (rx_done_tick)
- 
