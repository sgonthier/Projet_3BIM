extensions [palette]

patches-own
[
  temperature  ;; température du patch
  hauteur ;;relief du patch
  dispers_days ;; nombre de jours (été) où la dispersion a lieu
  winter_temp ;; période hivers
  summer_temp ;; période été
]

turtles-own [
  just-generated? ;; Type d'individu : larve ou papillon ? Si larve alors just-generated = true
]



globals
[
  dispers_season ;;période d'été durant laquelle les papillons se dispersent
  p-move ;; proba de déplacement 
  p-lay ;; proba de ponte
  p-death-butterfly ;; proba de mort à l'état papillon (à mettre en fonction de la température)
]


;;################ DEFINITION DE SETUP ET GO ###############################;;

to setup
  __clear-all-and-reset-ticks
  set-default-shape turtles "square"
  resize-world -100 100 -100 100
  create-turtles 100 [
    set color white
    set xcor random 200 - 100
    set ycor random 80 - 100
    set size 0.5
    set shape "bug" 
  ]
  ask patches[ 
  set dispers_days 122
  set hauteur 0 ;; par défaut il n'y a pas de relief
  ]
  set p-move 0.5
  set p-lay 0.1
  set p-death-butterfly 0.5
  mountain ;; création des zones de relief
  create-gradient ;;création du gradient de températures nord-sud
end



to go
  ask patches [
    ifelse (ticks <= dispers_days) ;; Définir dans quelle saison on se trouve. ifelse fonctionne comme suit : si true alors appliquer le bloc 1 sinon appliquer le bloc 2.
       [set dispers_season true]
       [set dispers_season false]
  ]


  ;; Les températures
  ask patches [
  ifelse (dispers_season);;saison de dispersion ? Si oui on est en été, sinon hivers
  
  
    ;;POUR L'ETE
    [   ifelse (ticks <= 61);; Au cours des 122 jours d'été les températures vont augmenter pendant 61 jours (jusqu'au milieu de l'été)
        [set temperature temperature + random-normal 0.16 0.03];; Augmentation de 0.16 degrés par jour avec une incertitude (loi normale)
        [set temperature temperature - random-normal 0.16 0.03 ];;puis revenir aux températures normales (depuis le milieu jusqu'à la fin de l'été)
        set temperature temperature + Heat-growth ;;prise en compte du réchauffement climatique sur 100 ans (les températures augmentent de 5.48e-5 degrés par jour)
        set pcolor scale-color red  temperature 27 15 ;;pour l'été : gradient de rouges
    ]
    
    ;;POUR L'HIVERS
    [  ifelse (ticks <= 244);;Si on se trouve avant le milieu de l'hivers
       [set temperature temperature - random-normal 0.084 0.03 ];; les températures descendent de 0.084 degrés par jour
       [ set temperature temperature + random-normal 0.084 0.03 ];; après elles reviennent aux normales
       set temperature temperature + Heat-growth ;; prise en compte du réchauffement climatique
       set pcolor scale-color blue  temperature 5 17;; pour l'hivers : gradient de bleu
    ]

  ]
  
  ;;DISPERSION
  check-death ;;mortalité au stade papillon
  move-turtles
  lay-turtles ;;ponte incluant la mortalité au stade oeuf

  ;;A chaque pas de temps "go" un tick (= 1 jour) passe
  tick
  
  ;;Au bout de 365 ticks, une année passe, on remet le compteur à 0
  if (ticks > 365) [
    reset-ticks
  ]

end



;;############### A PARTIR D'ICI ON DEFINIT LES FONCTIONS UTILISEES DANS SETUP ET GO ########################;;

;;CREATION DES RELIEFS;; 

to mountain
  ask patches[

  if (pxcor > 0) and (pxcor < 60) and (pycor < 0) and (pycor > -60) ;;Le massif central
        [
               set pcolor red ;;utile pour visualiser la zone pendant le setup
               set hauteur 1200 - sqrt ((pxcor - 30) ^ 2 + (pycor + 30) ^ 2) * 40 ;;Définition du massif : au centre les hauteurs atteignent 1200m et diminuent lorsque l'on s'en éloigne   
               if (hauteur < 0) [set hauteur 0]
        ]


     if (pxcor > 75) and (pxcor < 101) and (pycor < -30) and (pycor > -90) ;;Les alpes
        [ set hauteur 3000 - sqrt ((pxcor - 100) ^ 2 + (pycor + 60) ^ 2) * 120  ;;Maximum de 3000m
          if (hauteur < 0) [set hauteur 0]
          set pcolor grey
        ]



     if (pxcor > 80) and (pxcor < 101) and (pycor < 40) and (pycor > 0) ;;Les Vosges
        [set hauteur 700 - sqrt ((pxcor - 100) ^ 2 + (pycor - 20) ^ 2) * 35 ;;Maximum de 700m
          if (hauteur < 0) [set hauteur 0]
          set pcolor white
        ]
  ]
end




;;CREATION DES GRADIENT DE TEMPERATURE SELON LATITUDE ET ALTITUDE;;

to create-gradient
  ask patches [
      let normalized-value  (pycor * world-width) /
                            (world-width * world-height)
      set temperature normalized-value  * -6 + 19 - (hauteur / 150) ;;Pour l'altitude on prend en compte le fait que la température diminue d'1 degré tous les 150m
  ]
end


to move-turtles
  ask turtles [
    if ((random-float 1) <= p-move) [
      right (random 3) * 90 ;;pour n'aller que dans 4 directions
      forward 1
    ]
  ]
end


to check-death ;;for butterflys 
  ask turtles [
    if ((random-float 1) <= p-death-butterfly) [ die ] ;; removes the turtle
  ]
end


to lay-turtles ;;ponte
  ask turtles [
    if (1 <= (count turtles-on patch-ahead 1)) [ ;;si il y a d'autres papillons avec lesquels s'accoupler
      if ((random-float 1) <= p-lay) [
        hatch (200 - ((random 5) + 10) * 200 / 100) ;;p-death = 10 à 15% pour les oeufs
        die
      ]
    ]
  ]
end
