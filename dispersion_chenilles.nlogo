extensions [palette]

patches-own
[
  temperature  ;; the current temperature of the patch
  density
  dispers_days ;; Number of days in which there are butterflies (can disperse)
]

turtles-own 
[
  fitness
  just-generated? ;;Boolean. If true this is a larvae.
  diffusion ;; diffusion rate
]

globals
[
  plate-size  ;; the size of the plate on which heat is diffusing
  ;; Used for scaling the color of the patches
  min-temp  ;; the minimum temperature at setup time
  max-temp  ;; the maximum temperature at setup time
  dispers_season ;; Boolean. If true this is the dispersion season (june to september)
]



to setup
  __clear-all-and-reset-ticks
  set-default-shape turtles "bug"
  resize-world -100 100 -100 100 ;; France dimensions (1 patch = 10km2)

;;Creation of turtles
  create-turtles 100 [
    set color white
    set xcor random 200 - 100 ;;First colonies on all the longitudes
    set ycor random 80 - 100 ;; But more in the south
    set size 0.5
    set fitness 15
  ]

;;Definition of the 122 days of the dispersion period (june to september)
  ask patches[
  set dispers_days 122
  ]

  create-gradient
  ask patches at-points [[-16 -16] [-15 -16] [-16 -15] [-15 -15]] [ set density 0 ]
end



to go

;;Define the season 
 ask patches [
    ifelse (ticks <= dispers_days)
       [set dispers_season true]
       [set dispers_season false]
  ]

;; Les températures : alternances été hivers avec une fine augmentation des températures (Heat-growth) dûe au réchauffement
  ask patches [
  ifelse (dispers_season)

    [
        set temperature temperature + 0.0246 
        set temperature temperature + Heat-growth
        set pcolor scale-color red  temperature 27 15
    ]
    [
       set temperature temperature - 0.0123
       set temperature temperature + Heat-growth
       set pcolor scale-color blue  temperature 5 17
    ]
  ]

;;Les tortues
  move-turtles
  survival
  reproduce
  
;;Tick correspondent aux jours, après 365 ticks début d'une nouvelle année
tick
  if (ticks > 365) [
    reset-ticks
  ]
end



to create-gradient
  ask patches [
      let normalized-value   (pycor * world-width) /
                            (world-width * world-height)
      set temperature normalized-value  * -6 + 19 ;;Création d'un gradient de températures nord-sud 
  ]

end



to move-turtles
  ask turtles [
      right random 360
      forward 1
  ]
end



to reproduce
  ask turtles [
    if fitness > birth-energy [
      set fitness fitness - birth-energy
      hatch 1 [ set fitness birth-energy ]
    ]
  ]
end

to survival
  ask turtles [
    if fitness <= 10 [die]
    if pcolor >= red [
      set fitness (fitness + 1)
    ]
  ]
  end

