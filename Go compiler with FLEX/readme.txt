Poalelungi Gabriel 331CC

1) Programul realizeaza urmatoarele operatii:

- Comentarii simple sau multi-linie

- Declaratii de variabile simple (ex: var x int) sau combinate cu initializare
  cu valori directe sau valori ale altor variabile
  (ex: var x int = 7 sau var a int = x);

- Declaratii alternative cu operatorul " := " (ex: k, l, m, n := 8, 9.0, false, "wow")
    - In cazul acesta nu merg declaratii alternative de tipul a := b

- Initializari simple a unor variabile deja declarate (ex: var x int \n x = 8)
    - De asemenea, nu merg atribuiri cu valori ale altor variabile (a = b)

- Declarari de functii
    - Se retin tipul parametrilor si parametrii
    - Se retine tipul valorii returnate de functie
    - Toate operatiile descrise mai sus tin cont de vizibilitatea in bloc

2) Toate variabilele declarate de un anumit tip sunt retinute intr-un vector de acel tip.
   De asemenea, se retine si din ce functie face parte variabila, astfel incat 2 variabile
   cu acelasi nume, dar in functii separate, sa existe.

3) Se afiseaza erori in urmatoarele situatii:
    - Daca tipul variabile nu corespune valorii atribuite, fie ea din alta variabila;
    - Daca o variabila a fost redeclarata in acelasi bloc;
    - Daca mai exista o functie cu acelasi nume;
    - Daca functia nu are tip si are apelul return
    - Daca tipul functiei nu corespunde valorii returnate
    - Daca se redeclara o variabila existenta folosind " := "

4) Probleme existente:
    - Daca o variabila a fost declarata cu "var" si i s-a atribuit o valoare a unei alte variabile
      (ex: var a int = b), atunci operatia " a := 9" nu va afisa "No new variables
      on the left side of := "
    - Pentru o variabila declarata, dar neinitializata, nu i se poate atribui o valoare a unei alte variabile
      (ex: var a int; a = b)

5) Programul a fost realizat folosind VSCode, interpretatorul FLEX si GCC

6) 1200 linii de cod ftw. Sunt sigur ca se putea cu mai putin si sunt sigur ca mai mult nu se poate
7) Explicatii pentru fiecare stare in parte se afla in comentariile codului