-- Wyszuka� czytelnik�w, kt�rzy wypo�yczyli ksi��ki co najmniej 3 r�nych autor�w.
Use BIBLIOTEKA
--SELECT * FROM Czytelnicy
SELECT
	C.login AS 'LoginCzytelnik',
	COUNT(DISTINCT K.id_autor) AS 'IloscAutorzy'
FROM
	Wypozyczenia W
JOIN Ksiazki K ON W.id_ksiazka = K.id_ksiazka
JOIN Czytelnicy C ON W.id_czytelnik = C.id_czytelnik
GROUP BY
	C.id_czytelnik, C.login
HAVING 
	COUNT(DISTINCT K.id_autor) >= 3
ORDER BY
	C.login;

-- Spo�r�d ksi��ek kt�re posiadaj� co najmniej jedno wypo�yczenie przygotowa� podsumowanie ilo�ci ksi��ek per wydawnictwo.
-- MO�NA GRUPOWA� NIE TRZEBA WY�WIETLA�
SELECT
	WD.nazwa AS 'Wydawnictwo',
	COUNT(DISTINCT WP.id_ksiazka) AS 'IloscKsiazekWypozyczonych'
FROM 
	Wypozyczenia WP
JOIN Ksiazki K ON WP.id_ksiazka = K.id_ksiazka
JOIN Wydawnictwa WD ON K.id_wydawnictwo = WD.id_wydawnictwo
GROUP BY
	WD.id_wydawnictwo, WD.nazwa
HAVING
	COUNT(WP.id_ksiazka) >= 1
ORDER BY
	WD.nazwa;

-- Utworzy� widok o nazwie "ksiazki_popularne" przedstawiajacy podzbi�r ksi��ek kt�re zosta�y wypo�yczone przez conajmniej dw�ch czytelnik�w.

CREATE VIEW ksiazki_popularne AS
	SELECT 
		*
	FROM
		Ksiazki K
	WHERE 
		K.id_ksiazka IN (SELECT W.id_ksiazka FROM Wypozyczenia W GROUP BY W.id_ksiazka HAVING COUNT(DISTINCT W.id_czytelnik) >= 2); 

-- Wyszukaj pary dw�ch r�nych autor�w, kt�rych ksi��ki zosta�y wypo�yczone przez tego samego czytelnika i maj�cych to samo imi�.

SELECT
	A1.imie AS 'ImiePierwszy',
	A1.nazwisko AS 'NazwiskoPierwszy',
	K1.tytul AS 'TytulPierwszy',
	W1.id_czytelnik AS 'Czytelnik',
	A2.imie AS 'ImieDrugi',
	A2.nazwisko AS 'NazwiskoDrugi',
	K2.tytul AS 'TytulDrugi'
FROM
	Autorzy A1
JOIN Ksiazki K1 ON A1.id_autor = K1.id_autor
JOIN Wypozyczenia W1 ON K1.id_ksiazka = W1.id_ksiazka
JOIN Wypozyczenia W2 ON W1.id_czytelnik = W2.id_czytelnik AND W1.id_wypozyczenie <> W2.id_wypozyczenie AND W1.id_ksiazka <> W2.id_ksiazka
JOIN Ksiazki K2 ON W2.id_ksiazka = K2.id_ksiazka
JOIN Autorzy A2 ON K2.id_autor = A2.id_autor
WHERE
	A1.imie = A2.imie AND A1.id_autor <> A2.id_autor;

-- Spo�r�d ksi��ek kt�re posiadaj� co najmniej jedno wypo�yczenie przygotowa� podsumowanie ilo�ci ksi��ek per autor
SELECT * FROM Wypozyczenia
SELECT * FROM Ksiazki
SELECT * FROM Autorzy
SELECT
	A.imie AS 'ImieAutor',
	A.nazwisko AS 'NazwiskoAutor',
	COUNT(DISTINCT W.id_ksiazka) AS 'LiczbaKsiazki'
FROM
	Wypozyczenia W
JOIN Ksiazki K ON W.id_ksiazka = K.id_ksiazka
JOIN Autorzy A ON K.id_autor = A.id_autor
GROUP BY
	A.id_autor, A.imie, A.nazwisko
ORDER BY
	A.nazwisko;

-- Utworzy� tabel� "ksiazki_lit-piekna" komend� SELECT INTO z�o�on� z ksi��ek z literatury pi�knej oraz poezji. 
-- Nast�pnie komend� DELETE usun�� pozycje, kt�re nigdy nie by�y wypo�yczone.
SELECT * INTO ksiazki_lit_piekna1 FROM Ksiazki K WHERE K.id_kategoria IN (SELECT KG.id_kategoria 
FROM Kategorie KG WHERE KG.nazwa = 'Literatura pi�kna' OR KG.nazwa = 'Poezja');

DELETE FROM ksiazki_lit_piekna1 WHERE ksiazki_lit_piekna1.id_ksiazka NOT IN (SELECT W.id_ksiazka FROM Wypozyczenia W);