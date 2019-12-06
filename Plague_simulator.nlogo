globals
[
  nb_infecte_tick_pre ;;nbr infectés au tick précédent
  factor-obstacles
  max-angle-turn
  nb-tick
]

breed [humains humain]
breed [houses house]
breed [offices office]
breed [hospitals hospital]


humains-own
[
  myHouse
  going-home?
  turn-check
  wall-turn-check
  infecte?
  gueri?
  susceptible?
  mort?
  duree_infection
  temps_guerir ;; temps en heures pour guérir
  obstacles

  nb_infecte
  nb_gueri
]

to setup
  clear-all
  set factor-obstacles 0.9
  set max-angle-turn 80
  setup-environment
  setup_population
  dessine-graphes
  set nb-tick 0
  reset-ticks
end

to find-obstacles
  set obstacles patches in-cone 5 90 with [pcolor = yellow]
end

to setup-environment
  ;; Houses
  create-houses 1 [
    setxy -15 15
    set shape "house"
    set color brown
    set size 3
  ]

  create-houses 1 [
   setxy -15 -15
   set shape "house"
   set color brown
   set size 3
  ]

  create-houses 1 [
    setxy 15 15
    set shape "house"
    set color brown
    set size 3
  ]

  create-houses 1[
   setxy 15 -15
   set shape "house"
   set color brown
   set size 3
  ]

  create-houses 1[
    setxy 15 0
    set shape "house"
    set color brown
    set size 3
  ]

  create-houses 1[
    setxy -15 0
    set shape "house"
    set color brown
    set size 3
  ]

  create-houses 1 [
    setxy 0 -15
    set shape "house"
    set color brown
    set size 3
  ]

;  create-houses 1 [
;    setxy 0 15
;    set shape "house"
;    set color brown
;    set size 3
;  ]

  create-offices 1 [
    setxy 0 0
    set shape "house colonial"
    set color brown
    set size 4
  ]

  create-hospitals 1 [
    setxy 0 15
    set shape "house ranch"
    set color brown
    set size 5
  ]

  ;; Roads
  ask patches with [pycor = 0 OR pycor = 1 OR pycor = -1] [ set pcolor grey ]
  ask patches with [pxcor = 0 OR pxcor = 1 OR pxcor = -1] [ set pcolor grey ]
  ask patches with [pxcor = pycor] [ set pcolor grey ]
  ask patches with [pxcor * -1 = pycor] [ set pcolor grey ]
  ask patches with [pxcor = pycor + 1] [ set pcolor grey ]
  ask patches with [pxcor = pycor - 1] [ set pcolor grey ]
  ask patches with [pxcor * -1 = pycor + 1] [ set pcolor grey ]
  ask patches with [pxcor * -1 = pycor - 1] [ set pcolor grey ]
  ask patches with [pxcor = max-pxcor] [ set pcolor grey ]
  ask patches with [pxcor = max-pxcor + 1] [ set pcolor grey ]
  ask patches with [pxcor = max-pxcor - 1] [ set pcolor grey ]
  ask patches with [pxcor = min-pxcor] [ set pcolor grey ]
  ask patches with [pxcor = min-pxcor + 1] [ set pcolor grey ]
  ask patches with [pxcor = min-pxcor - 1] [ set pcolor grey ]
  ask patches with [pycor = max-pycor] [ set pcolor grey ]
  ask patches with [pycor = max-pycor + 1] [ set pcolor grey ]
  ask patches with [pycor = max-pycor - 1] [ set pcolor grey ]
  ask patches with [pycor = min-pycor] [ set pcolor grey ]
  ask patches with [pycor = min-pycor + 1] [ set pcolor grey ]
  ask patches with [pycor = min-pycor - 1] [ set pcolor grey ]
end

to draw-house
  if mouse-down? [
    create-houses 1 [
      setxy mouse-xcor mouse-ycor
      set shape "house"
      set color brown
      set size 3
    ]
  ]
end

to wall-draw ;; Use the mouse to draw buildings.
  if mouse-down?
    [
      ask patch mouse-xcor mouse-ycor
        [ set pcolor yellow ]]
end

to setup_population

  create-humains population_initiale
  [
    setxy random-xcor random-ycor
    set myHouse one-of houses

    set gueri? false
    set infecte? false
    set susceptible? false
    set mort? false
    let r random 2
    ifelse r = 0 [set going-home? false] [set going-home? true]
    set shape "person"
    set color white

    ;;temps de guerison de chaque individu est une distribution normale autour de la moyenne de temps de guerison
    set temps_guerir random-normal chance_guerison chance_guerison / 4


    ;;faire en sorte que ça soit entre 0 et 2x la moyenne du temps de guerison
    if temps_guerir > chance_guerison * 2 [
      set temps_guerir chance_guerison * 2
    ]
    if temps_guerir < 0 [ set temps_guerir 0 ]

    if(random-float 100 < probabilite_infection)
    [
      set infecte? true
      set susceptible? false
      set duree_infection random temps_guerir
    ]

    assigner_couleur


  ]

end

to assigner_couleur

  if infecte?
  [
    set color red
  ]
  if gueri?
  [
    set color green
  ]
  if not infecte? and not gueri? and susceptible?
  [
    set color yellow
  ]

end



to go

;  if all? (humains with [ not mort? ]) [not infecte?]
;  [ stop ]

  if remedy-exists [
    set chance_guerison chance_guerison + avancement-per-tick
  ]

  if nb-tick = 200 [stop]

  ask humains with [not mort? ]
  [
    move
    clear-compte
  ]

  ask humains with [ infecte? and not mort? ]
  [
    infecter
    pttr_guerir
  ]

  ask humains with [ gueri? and not mort?]
  [
    if maladie_evolutive
    [
      if  nb-tick < duree_incubation
      [
        if random-float 100 < chance_rechuter
        [
          set gueri? false
          set susceptible? true
        ]
      ]
    ]

  ]

  ask humains
  [
    assigner_couleur
  ]

  dessine-graphes
  set nb-tick (nb-tick + 1)
end

to dessine-graphes
  set-current-plot "infectés"
  set-current-plot-pen "infecté"
  plot count humains with [infecte?]
  set-current-plot-pen "non-infecté"
  plot count humains with [not infecte?]

  set-current-plot "Guerison"
  set-current-plot-pen "gueri"
  plot count humains with [gueri?]
  set-current-plot-pen "non-gueri et infectés"
  plot count humains with [not gueri? and infecte?]

  set-current-plot "morts"
  set-current-plot-pen "mort"
  plot count humains with [mort?]

;  output-print nb-tick
  output-print (count humains with [mort?])
end

to wall ;;  Turn agent away from wall
;    set wall-turn-check random 10
;    if wall-turn-check >= 6
;    [wall-right-turn]
;    if wall-turn-check <= 5
;    [wall-left-turn]


end

to wall-right-turn ;;Generate a random degree of turn for the wall sub-routine.
  rt 170
end

to wall-left-turn ;;Generate a random degree of turn for the wall sub-routine.
  lt 170
end

to right-turn ;;Generate a random degree of turn for the wander sub-routine.
  rt random-float 10
end

to left-turn   ;;Generate a random degree of turn for the wander sub-routine.
  lt random-float 10
end

to move
  ;ifelse [pcolor] of patch-ahead 1 != black AND [pcolor] of patch-ahead 1 != grey AND [pcolor] of patch-ahead 1 != cyan [wall]

  find-obstacles
  ifelse any? obstacles [
      let va angleFromVect vectObstacles
      turn-towards va max-angle-turn
  ][

    ifelse infecte? [
      face one-of hospitals
    ][

  ifelse going-home? [
    face myHouse
    if any? houses in-radius 1 [set going-home? false]
    rt random-float 90
    lt random-float 90
  ][
    face patch 0 0
     rt random-float 90
    lt random-float 90
    if any? offices in-radius 2 [set going-home? true]
  ]
  set turn-check random 50
  ifelse turn-check > 25 [right-turn] [left-turn]
  ]
  ]
  fd 0.2
end

to clear-compte

  set nb_infecte 0
  set nb_gueri 0

end

to infecter

  let non_infecte_proche (humains-on neighbors) with [not infecte? and not gueri?]

  if non_infecte_proche != nobody
  [


    ask non_infecte_proche
    [
;      if random-float 100 < probabilite_infection
;      [
        set infecte? true
        set nb_infecte (nb_infecte + 1)
        set duree_infection 0
        ;Permet de montrer les zones ou les gens sont le plus contaminés
;        ]
    ]
  ]
end

to pttr_guerir

  set duree_infection (duree_infection + 1)

  ifelse duree_infection > temps_guerir
  [
    ifelse random-float 100 < chance_guerison
   [
     set infecte? false
     set gueri? true
     set nb_gueri (nb_gueri + 1)
    ][
;      if random-float 100 < chance_mourir[
;        set shape "caterpillar"
;        set mort? true
;      ]
      if duree_infection >= duree_incubation[
        if random-float 100 < chance_mourir[
          set shape "caterpillar"
          set mort? true
          if show_place = true [
          set pcolor cyan
          ]
        ]
      ]

    ]
  ]
  [
;    if random-float 100 < chance_mourir
;    [
;      set shape "caterpillar"
;      set mort? true
;    ]
  ]


end


to turn-towards [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end

to turn-away [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end

;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [turn max-turn]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end

to-report multiplyScalarvect [factor vect]
   report (list (item 0 vect * factor) (item 1 vect * factor))
end
to-report additionvect [v1 v2]
   report (list (item 0 v1 + item 0 v2) (item 1 v1 + item 1 v2) )
end
to-report vectFromAngle [angle len]
   let l (list (len * sin angle) (len * cos angle))
   report l
end

;;
to-report angleFromVect [vect]
    let a atan item 0  vect item 1 vect
    report a
end

;to-report vectDirect
;  let vo multiplyScalarvect factor-obstacles vectObstacles
;
;  set vr additionvect vo multiplyScalarvect (1 - factor-obstacles) vr
;  report vr
;;
;end



;;; SEPARATE

to-report vectObstacles
  let dist 0
  let vo (list 0 0)
  if any? obstacles [
    let nearest-patch min-one-of obstacles [distance myself]
    set dist distance nearest-patch
    set vo VectFromAngle (towards nearest-patch - 180) (1 / distance nearest-patch)
  ]
  report vo

end
@#$#@#$#@
GRAPHICS-WINDOW
791
10
1332
552
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

SLIDER
40
32
212
65
population_initiale
population_initiale
0
1000
700.0
1
1
NIL
HORIZONTAL

SLIDER
247
35
419
68
chance_rechuter
chance_rechuter
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
429
34
601
67
chance_guerison
chance_guerison
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
39
78
211
111
probabilite_infection
probabilite_infection
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
248
76
420
109
duree_incubation
duree_incubation
0
500
70.0
1
1
NIL
HORIZONTAL

BUTTON
253
120
316
153
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
348
120
411
153
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
390
292
786
594
infectés
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"infecté" 1.0 0 -2674135 true "" "plot count humains with [ infecte? ]"
"non-infecté" 1.0 0 -13840069 true "" "plot count humains with [ not infecte? ]"

SWITCH
429
74
601
107
maladie_evolutive
maladie_evolutive
0
1
-1000

SLIDER
41
122
213
155
chance_mourir
chance_mourir
0
100
80.0
1
1
NIL
HORIZONTAL

PLOT
41
165
201
285
morts
NIL
NIL
0.0
500.0
0.0
500.0
true
true
"" ""
PENS
"mort" 1.0 0 -16777216 true "" "plot count humains with [mort? = true]"

PLOT
10
292
388
595
Guerison
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"gueri" 1.0 0 -11221820 true "" "plot count humains with [ gueri? ]"
"non-gueri et infectés" 1.0 0 -8431303 true "" "plot count humains with [ not gueri? and infecte?]"

BUTTON
469
118
555
155
Draw Walls
wall-draw
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
248
171
368
204
show_place
show_place
0
1
-1000

OUTPUT
410
212
650
266
11

SWITCH
247
214
370
247
remedy-exists
remedy-exists
0
1
-1000

SLIDER
614
33
786
66
avancement-per-tick
avancement-per-tick
0
5
0.06
0.01
1
NIL
HORIZONTAL

TEXTBOX
413
196
563
214
Nombre de morts
11
0.0
1

@#$#@#$#@
# PLAGUE SIMULATOR

## QU'EST CE QUE C'EST ?

Ce projet est une simulation explicitant les effets de propagation des maladies infectieuses au sein d'une société.

## COMMENT CA MARCHE

Les agents se déplacent selon un pattern leur imposant de faire des aller-retours entre leurs domiciles et leur lieu de travail représenté par le batiment situé au centre de la simulation.

Lorsque les agents sont infectés, ils se dirigent vers l'hopital représenté par le batiment en haut de la simulation.

Il est possible de modifier les paramètres suivant pour influer sur les résultats de la simulation:
	- Population initiale
	- Chance de rechuter (pour les maladies évolutives)
	- Chance de guérison
	- Avancement par tick: Taux d'augmentation de la chance de guérison par tick représentant l'avancée médicale sur la maladie définie
	- Probabilité d'infection
	- Durée d'incubation
	- Maladie évolutive ou non: Les agents peuvent être infectés même s'ils ont déjà été guéris
	- Chance de mourir: Pourcentage de létalité de la maladie
	- Show place: Coloration des patch sur lequels des agents meurent à cause de la maladie
	- Remedy-exists: Possibilité d'avancement médical sur la maladie
	- Draw-walls: Permet de déssiner des obstacles que les agents sont programmés à éviter

## COMMENT L'UTILISER

Pour utiliser ce modèle:
	1. Fixer les paramètres définis ci-dessus
	2. Cliquer sur setup
	3. Pour déssiner des obstacles, cliquer sur *Draw walls* puis utiliser la souris pour dessiner
	4. Cliquer sur *go* pour lancer la simulation
	NB: La simulation s'arrête après 200 ticks

## EXEMPLES D'UTILISATION 

Choléra:
	- Chance de guérison 80
	- Probabilité d'infection: 15
	- Durée d'incubation: 30
	- Maladie évolutive: Non
	- Chance de mourir: 20
	- Remède éxistant: Oui
	- Avancement par tick: 0 (Le remède éxiste déjà)

Peste:
	- Chance de rechuter: 75
	- Chance de guérison: Entre 0 et 5
	- Probabilité d'infection: 50
	- Durée d'incubation: 70
	- Maladie évolutive: Oui
	- Chance de mourir: 80
	- Remède éxistant: Oui
	- Avancement par tick: Au choix (Selon l'époque)

## EXTENSION DU MODELE

Pour étendre ce modèle, nous pouvons ajouter des patterns plus développés pour les agents pour expliciter les lieu à hauts risques de contagion.


## MODELES EN RELATION

Infectious Disease Model: http://www.personal.kent.edu/~mdball/Infectious_Disease_Model.htm

## CREDITS ET REFERENCES

Ce modèle a été créé dans le cadre d'un projet de recherche à la Faculté des sciences de l'Université de Montpellier par Inès Benghezal et Yasmine Khodja.

Une feuille ou certains résultats ont été notés peut être trouvée en suivant ce lien: https://docs.google.com/spreadsheets/d/15RGbbegAQTcCgGti3s5_1tIoF_P5tlVo0yC0CMM6yqk/edit?usp=sharing


###  Copyright (c) 2019 Inès Benghezal and Yasmine Khodja. All rights reserved.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
