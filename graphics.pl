:- dynamic personnage/3.
:- dynamic policier/1.
:- dynamic case/2.

% ---- PARTIE GRAPHIQUE (questions, affichage des reponses, des choix etc) ----
g_NettoieEcran :- nl,
    write('\e[2J'),
    g_Titre. % TODO: (pourquoi pas) avoir une liste global de prédicat a appeler quand l'ecran est nettoyer,
             %                      ca permettrait de remettre instantanement les info actuellement relevants.

g_NettoieEcranMaisAttendUnPeutQuandMeme :- nl,
    write('Appuyer sur entrer pour effacer l\'ecran et continuer.'),
    current_input(Stream), read_pending_codes(Stream, _, _), % vide le buffer du input stream (sinon ca override le get_char, wtf prolog)
    get_char(_), % attend qu'on appuie sur 'enter'
    current_input(Stream), read_pending_codes(Stream, _, _), % re-vide le buffer (si on a entrer d'autre charactères avant 'entrer') pour pas casser le pauvre interpreter qu'a l'air d'avoir deja bien du mal avec la catastrophe qu'est le language qu'on l'oblige a lire... btw ma touche 'a' commence a me lacher... et la '1' aussi...
    g_NettoieEcran.

g_Titre :- nl,
    writeln('      -------------------------------- '),
    writeln('     |       10 MINUTES TO KILL       |'),
    writeln('     |       ~ A PROLOG GAME! ~       |'), 
    writeln('      -------------------------------- ').

g_QPourQuitter :- nl,
    writeln('(q pour quitter)').

g_QuestionNbJoueurs :- nl,
    write('     Combien de joueurs vont participer (2 a 4 max) ?'),
    g_QPourQuitter.

g_QuestionChoisireCase :- nl,
    write('     Choisissez une case (entrez X,Y)').

g_Repondre(Choix) :- nl,
    write('      --> Votre choix (avec un point a la fin) : '),
    read(Choix).

g_ChoixNonExistant :- nl,
    writeln('     Erreur: ce choix n\'est pas disponible. Veuillez recommencer.').

g_NbJoueurs(NbJoueurs) :- nl,
    write('           ---- '), nl,
    write('          | -> | Cette partie a '), write(NbJoueurs), writeln(' joueurs'),
    write('           ---- '), nl.

g_Joueurs(ListeJoueurs) :-
    write('          Ces joueurs sont : '),
    writeln(ListeJoueurs).

g_DebutPartie :- nl, nl,   
    writeln('      -------------------------------- '),
    writeln('     |     QUE LA PARTIE COMMENCE !   |'),
    writeln('      -------------------------------- '),
    g_NettoieEcranMaisAttendUnPeutQuandMeme.

g_JoueurEnCours(JoueurEnCours, N) :- nl,
    write('          C\'est au tour de : '), write(JoueurEnCours), write(' (joueur no '), write(N), write(')').

g_EtatAction(I) :- nl,
    write('           --------------- '), nl,
    write('          | Action no '), write(I), writeln('/2 |'),
    write('           --------------- '), nl.

g_QuestionActionSouhaitee :- nl,
    writeln('     Que voulez-vous faire ?'), nl, nl,
    writeln('          --> AGIR <--'), nl,
    writeln('      ---                            ---'),
    writeln('     | 1 | Deplacer un personnage   | 2 | Eliminer un personnage'),
    writeln('      ---                            ---'), 
    writeln('      ---  Controler l\'identite     '),
    writeln('     | 3 |   d\'un personnage a      '),
    writeln('      ---  l\'aide d\'un policier    '), nl, nl,
    writeln('          --> ou CONSULTER <--'), nl,
    writeln('      ---                            ---      Consulter les    '),
    writeln('     | 4 | Voir le plateau          | 5 | personnages/policiers'),
    writeln('      ---                            ---        vivants       '),
    writeln('      ---                            '),
    writeln('     | 6 | Se faire conseiller       '),
    writeln('      ---                            ').

g_PersonnagesVivant(ListePersonnages) :- nl,
    writeln(ListePersonnages).

g_PersonnagesSurCase(Pos, ListePersonnages) :- nl,
    write('Les personnages sur la case '), write(Pos), write(' sont :'),
    g_PersonnagesVivant(ListePersonnages).

% ---- PARTIE PLATEAU ----
% +----+
% | Px | -> 'P' si ya un policier, 'x' si c'est une case sniper
% | 42 | -> nombre de personnages sur la case (policiers non comptes)
% +----+

displCaseExist(Pos, L, EstSniper) :-
    L == 0,               %   if (L == 0) première ligne
        write('+----') ,!
    ; L == 1,               %   if (L == 1) ligne ?policier et ?sniper
        write('| '),
        ( personnage(Perso, Pos, vivant), policier(Perso),
            write('P') ,!
        ;
            write(' ')
        ),
        ( EstSniper == true,
            write('x') ,!
        ;
            write(' ')
        ),
        write(' ') ,!
    ; L == 2,               %   if (L == 2) ligne nombre de perso
        findall(I, (personnage(I,Pos,vivant), \+ policier(I)), Personnages),
        length(Personnages, Nombre),
        write('| '),
        format('~|~` t~d~2+', [ Nombre ]),
        write(' ').

displCaseVide((X,Y), L) :-
    X2 is X-1, Y2 is Y-1,
    (
        L == 0, ( % if (ligne 0 
            case((X,Y2), _), % ET case au dessu exist)
            write('+----') ,!
        ) ; ( % else
            case((X2,Y), _), % if (case a gauche existe)
                ( L == 0, write('+') ,!; write('|') ) ,!
            ; % else (le + c'est pour les angles bas-droit des extemitées)
                L == 0,case((X2,Y2), _), write('+') ,!; write('.')
        ), write('....')
    ).

% affiche une case si elle existe, sinon une case vide
displCase(Pos, L) :-
    case(Pos, EstSniper),   % if (il existe une case a Pos) {
        displCaseExist(Pos, L, EstSniper) ,!
    ;                       % } else
        displCaseVide(Pos, L).

% affiche les numéros sur le côté gauche
displNumLigne(J, L) :-
    ( L == 1,
        format('~|~` t~d~2+', [ J ]), write('   ') ,!
    ;
        write('     ')
    ).

% affiche les numéros en haut
displNumColonnes(N) :-
    write('   Y '),
    between(0, N, I),
        format('~|~` t~d~3+', [ I ]), write('  '),
    fail.

trouveTailleTerrain(TaillX, TaillY) :-
    findall(X, case((X,_), _), ListX),
    findall(Y, case((_,Y), _), ListY),
    max_list(ListX, TaillX),
    max_list(ListY, TaillY).

% verticalement : permière coordonnée (numéro colonne)
displTerrain() :-
    trouveTailleTerrain(MaxX, MaxY),

    % les limites sont +1 pour afficher le contours bas et droite des cases au bord bas droit du terrain
    LimX is MaxX+1, LimY is MaxY+1,

    nl, write('  '), \+ displNumColonnes(MaxX),
    nl, write('  '), write(' X '),

    between(0, LimY, J),
        % scanlines (chaque case fait 3 lignes)
        between(0, 2, L),
            nl, write('  '),
            % comme on va jusqu'a taille+1, on skip dès qu'on a atteint la limite
            ( J == LimY, write('     ') ,!; displNumLigne(J, L) ),
            between(0, LimX, I),
                displCase((I, J), L),
            I == LimX,
        L == 2,
    J == LimY.

g_Terrain :-
    \+ displTerrain(), nl.