globals
[
  ;;PATTERNS;;
  patterns_colors       ;; id/color definissant un pattern
  patterns_weights      ;; ratio qui represente le pattern sur la fenetre d'affichage

  lnk_id_cnt
]

patches-own
[
  patch_pattern         ;; pattern id/color associe a ce patch
  patch_partition       ;; partition associee a ce patch
]


breed [particules particule] ;; particule represente les positions finales a atteindre; turtle "fictive" utilise uniquement pour des calculs, ici le centre d'une partion voronoi
particules-own
[
  particule_pattern      ;; pattern associe
  particule_partition    ;; partition associee
]


breed [robots robot]
robots-own
[
  velocity               ;; vector (x,y) representant la vitesse actuelle
  pref_velocity          ;; vector (x,y) reprensentant la vitesse preferee càd celle qui amene le robot a son objectif
  new_velocity           ;; vector (x,y) reprensentant la vitesse a l'etape suivante
  orca_lines             ;; ensemble contraintes/lignes orca definissant la frontiere entre les vitesses valables et les vitesses de collision
  collision_neighbors    ;; ensemble d'agents dans le radius de detection càd presntant un risque de collision
  goal                   ;; objectif a atteindre pour cette etape, a chaque etape calculer nouveau objecif en utilisant algo hongrois
]


directed-link-breed [red-links red-link] ;; utilise pour dessiner le vecteur vitesse
breed [lnks lnk] ;; turtle "fictive" utilis pour tracer les lignes orca
lnks-own
[
  lnk_id
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ███████ ███████ ████████ ██    ██ ██████
;; ██      ██         ██    ██    ██ ██   ██
;; ███████ █████      ██    ██    ██ ██████
;;      ██ ██         ██    ██    ██ ██
;; ███████ ███████    ██     ██████  ██
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup_default ;; import png inclus dans dossier base
  clear-all
  display_construction?
  output-print "--SETUP STARTED--"
  initContext
  importDefaultPatterns
  generateGoals
  generate_robots
  output-print "--SETUP ENDED--"
  display
end

to setup ;; import png qlconque, permet a l'utilisateur de parcourir ces fichiers
  clear-all
  display_construction?
  output-print "--SETUP STARTED--"
  initContext
  importPatterns
  generateGoals
  generate_robots
  output-print "--SETUP ENDED--"
  display
end

to initContext ;;initialise le contexte de base
  set patterns_colors []
  set patterns_weights []
  set-default-shape particules "x"
  ;;set-default-shape robots "circle"
  set-default-shape robots "circle 3"
end

to display_construction?
  reset-ticks
  ifelse (show_particules or show_partitions or show_grid)
  [display]
  [no-display]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ██████   █████  ████████  ██████ ██   ██ ███████ ███████
;; ██   ██ ██   ██    ██    ██      ██   ██ ██      ██
;; ██████  ███████    ██    ██      ███████ █████   ███████
;; ██      ██   ██    ██    ██      ██   ██ ██           ██
;; ██      ██   ██    ██     ██████ ██   ██ ███████ ███████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to create_particule [ id ] ;; spawns une particlue associée a la partition id dans le patch appelant
  sprout-particules 1 [

    set particule_pattern patch_pattern
    set particule_partition id

    set color particule_pattern
    ifelse show_particules
    [
      set size robot_size
    ]
    [
      set size 0
    ]
  ]
end


to calculate_partitions  ;; calcule la partition associee
  if (patch_pattern != "null")
  [
    let p patch_pattern
    set patch_partition [particule_partition] of min-one-of (particules with [particule_pattern = p]) [distance myself]
    if show_partitions
    [
      set pcolor [particule_partition] of min-one-of (particules with [particule_pattern = p]) [distance myself]
    ]
  ]
end

to create_robot ;; spawns un robot dans le patch appelant
  sprout-robots 1 [
    set size robot_size
    set velocity list (0) (0)
    set new_velocity list 0 0

    ;; TODO: a virer une fois ayant l'algo hongrois
    set goal [who] of (particule (who - number_of_robots ))
    ;;set color [color] of (particule (who - number_of_robots ))
    ;;set pref_velocity list ([xcor] of particule (who - number_of_robots ) - xcor) ([ycor] of particule (who - number_of_robots ) - ycor)

  ]
end

to generate_robots ;; genere des robots de façon a ne pas avoir des robots superposes
  output-print "Generating Robots "
  output-print "Making sure they don't overlap... "

  let pos ((robot_size) / 2)
  let n_slots floor (world-width / (robot_size))
  let available_slots []
  ;;let available_slots_y ( range n_slots )

  foreach ( range (n_slots - 1))[ x ->
    foreach ( range (n_slots - 1))[ y ->
      set available_slots lput list (x) (y) available_slots
    ]
  ]

  let n_robots_spawned 0
  let i 0
  let coord 0
  let x 0
  let y 0

  if ( show_grid )[
    ask patches[
      if ((pxcor mod robot_size = 0) or (pycor mod robot_size = 0))[set pcolor red]
      if ((pxcor = 0) or (pycor = 0))[set pcolor green]
    ]
  ]


  while [ n_robots_spawned < number_of_robots] [

    set i random (length available_slots - 1)

    set coord item i available_slots
    set x (item 0 coord) + 1
    set y (item 1 coord) + 1
    set available_slots remove-item i available_slots

    if (x mod 2 = 0) [set x (- x + 1)]
    if (y mod 2 = 0) [set y (- y + 1)]

    set x (x * pos)
    set y (y * pos)

    ask patch x y [
      create_robot
    ]

    set n_robots_spawned (n_robots_spawned + 1)

  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ██████   ██████
;; ██       ██    ██
;; ██   ███ ██    ██
;; ██    ██ ██    ██
;;  ██████   ██████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  ;; nettoyage lignes affichage
  set lnk_id_cnt 0
  clear-drawing
  ask-concurrent lnks [
    die
  ]

  ;; mvmnt robots
  tick-advance 1
  ;; TODO: ajout calcul objectif et changement color algo hongrois
  ask robots [
    set_color_goal
    calculate_preferred_velocity
    calculate_new_velocity
  ]
  ask robots [ move_to_goal ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ██████   █████  ████████ ████████ ███████ ██████  ███    ██      ██████ ██████  ███████  █████  ████████ ██  ██████  ███    ██
;; ██   ██ ██   ██    ██       ██    ██      ██   ██ ████   ██     ██      ██   ██ ██      ██   ██    ██    ██ ██    ██ ████   ██
;; ██████  ███████    ██       ██    █████   ██████  ██ ██  ██     ██      ██████  █████   ███████    ██    ██ ██    ██ ██ ██  ██
;; ██      ██   ██    ██       ██    ██      ██   ██ ██  ██ ██     ██      ██   ██ ██      ██   ██    ██    ██ ██    ██ ██  ██ ██
;; ██      ██   ██    ██       ██    ███████ ██   ██ ██   ████      ██████ ██   ██ ███████ ██   ██    ██    ██  ██████  ██   ████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to importPatterns
  ask patches [
    set pcolor white
  ]
  ;; imports image et paint patches
  import-pcolors user-file
end

to importDefaultPatterns
  ask patches [
    set pcolor white
  ]
  let file word (word "DefaultPatterns/" defaul_pattern) ".png"
  ;; imports image et paint patches
  import-pcolors file
end

;; imports file, cree patterns data
to createPatterns
  ;; rempli patterns data (color, ratio)
  ask patches [
    ;; associe patch to pattern
    set patch_pattern pcolor
    ;; if patch color not in patterns_colors ajout, else increment
    ifelse not member? pcolor patterns_colors
    [
      set patterns_colors lput pcolor patterns_colors
      set patterns_weights lput 1 patterns_weights
    ]
    [
      let pattern_index (position pcolor patterns_colors)
      ;; increment pattern weight
      set patterns_weights replace-item pattern_index patterns_weights ( item pattern_index patterns_weights + 1 )
    ]
  ]
  ;; output de import-pcolors file a du bruit pixels de color legerement different qui poses des pb de calul
  ;; drop 'fake patterns': from last index to 0 at -1 pace
  foreach (range (length patterns_weights - 1) -1 -1) [ x -> drop_pattern x pattern_percentage ]
  ;;update ratio
  let total_ratio sum patterns_weights
  set patterns_weights map [x -> precision (x / total_ratio) 2] patterns_weights
  ;;nettoyage bruit: patches non white et non associes a un pattern
  ask patches
  [
    if not member? pcolor patterns_colors
    [
      set patch_pattern "null"
      set patch_partition "null"
    ]
    set pcolor white
  ]
end


to drop_pattern [x percentage] ;; drops pattern x if ratio < percentage
  let weight item x patterns_weights
  let ratio ( weight / count patches )

  ifelse ratio < percentage or item x patterns_colors = white
  [
    set patterns_colors remove-item x patterns_colors
    set patterns_weights remove-item x patterns_weights
  ]
  [
    set patterns_weights replace-item x patterns_weights ratio
  ]
end


to-report calcul_number_of_particules ;; calcule number_of_particules (robots) associe a pattern a partir de son ratio
  let number_of_particules []
  foreach (range length patterns_weights) [ id ->
    set number_of_particules lput round (item id patterns_weights * number_of_robots) number_of_particules
  ]
  let sum_particules sum number_of_particules
  let diff (sum_particules - number_of_robots)
  let max_n (max number_of_particules)
  set number_of_particules replace-item (position max_n number_of_particules) number_of_particules (max_n - diff)
  report number_of_particules
end


to pattern_generate_particules [number_of_particules p id] ;; genere number_of_particules particules starting from id to id+number_of_particules on pattern p
  ask n-of number_of_particules patches with [patch_pattern = p]
  [
    create_particule id
    set id (id + 1)
  ]
end


to generate_particules ;; genere particlues pour chaque pattern
  ;; start particules id at 0
  let particules_index 0
  let number_of_particules calcul_number_of_particules
  ;; pour chaque pattern calcule nombre necessaire de particules et genere
  foreach (range length patterns_weights) [ id ->
    pattern_generate_particules (item id number_of_particules) (item id patterns_colors) (particules_index)
    set particules_index (particules_index + (item id number_of_particules))
  ]
end


to-report calculateCentroids ;;calcule centroid pour toute partition. note: number of partitions = number of robots

  let partitions_n_patches n-values number_of_robots [0] ;; number of patches per partition
  let centroids_x n-values number_of_robots [0] ;; x coord for each partition centroid
  let centroids_y n-values number_of_robots [0] ;; y coord for each partition centroid

  ask patches with [ patch_partition != "null" ]
  [
      ;; increment nb of patches
      set partitions_n_patches replace-item patch_partition partitions_n_patches ( (item patch_partition partitions_n_patches) + 1)
      ;; increment x
      set centroids_x replace-item patch_partition centroids_x ( (item patch_partition centroids_x) + pxcor)
      ;;increment y
      set centroids_y replace-item patch_partition centroids_y ( (item patch_partition centroids_y) + pycor)
  ]

  let update_partition? false
  ;; update particule position to centroid position
  foreach (range number_of_robots) [ i ->
    if (item i partitions_n_patches) != 0
    [
      ask particules with [particule_partition = i]
      [
        let tmp_x xcor
        let tmp_y ycor
        set xcor ( (item i centroids_x) / (item i partitions_n_patches) )
        set ycor ( (item i centroids_y) / (item i partitions_n_patches) )
        set update_partition? (update_partition?) or (tmp_x - xcor > tessellation_convergence_goal) or (tmp_y - ycor > tessellation_convergence_goal)
      ]
    ]
  ]
  report update_partition?
end

to voronoi_tesselation ;; calcule nouveau centroid, nouvelle partion jusqu'a atteindre niveau de detail acceptable
  tick-advance 1
  ask patches [calculate_partitions]
  let voronoi_iteration 0
  while [calculateCentroids  and voronoi_iteration <= max_Voronoi_Tesselation_iterations]
  [
    tick-advance 1
    output-print word (word "___Voronoi_tesselation: runnig iteration " voronoi_iteration) "..."
    ask patches [calculate_partitions]
    set voronoi_iteration (voronoi_iteration + 1)
  ]
end

to generateGoals ;; genere les objectifs = positions finales
  createPatterns
  generate_particules
  voronoi_tesselation
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;██████   ██████  ██████   ██████  ████████ ███████
;;██   ██ ██    ██ ██   ██ ██    ██    ██    ██
;;██████  ██    ██ ██████  ██    ██    ██    ███████
;;██   ██ ██    ██ ██   ██ ██    ██    ██         ██
;;██   ██  ██████  ██████   ██████     ██    ███████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to set_color_goal
  set color [color] of (particule goal)
end

to calculate_preferred_velocity

  let preferred_speed(0.9 * max_speed)


  let g_x [xcor] of (particule goal)
  let g_y [ycor] of (particule goal)

  let relative_pos_to_goal list ( g_x - xcor) ( g_y - ycor )
  let len_relative_pos abs_ relative_pos_to_goal


  let k (preferred_speed * time_step * k_a_controller)

  let relpos/lenrelpos scale_vector (relative_pos_to_goal) (1 / len_relative_pos )
  let lenrelpos/k (len_relative_pos / k)
  let m min (list (1) (lenrelpos/k))
  set pref_velocity scale_vector (relpos/lenrelpos) (preferred_speed * m)

end




to calculate_new_velocity
  ;; TODO : changer de façon a calculer pref velocity en accor avec le sujet
  ;;set pref_velocity scale_vector normalize_vector (list ([xcor] of particule (who - number_of_robots ) - xcor) ([ycor] of particule (who - number_of_robots ) - ycor)) (0.9 * max_speed)
  set collision_neighbors other robots in-radius collision_detection_range
  compute_new_velocity_ORCA
end


to move_to_goal
  set velocity new_velocity
  setxy (xcor + item 0 velocity) (ycor + item 1 velocity)
end



;;Note:
;;     Ayant trouvé l'application mathématique du sujet partie ORCA compliqué nous nous sommes aidé
;;     de l'implémentation déjà existante du problème présenté en [18]
;;     - J. van den Berg, S. J. Guy, M. Lin and D. Manocha, ”Reciprocal nbody Collision Avoidance”, in Int. Symp. on Robotics Research, 2009. -
;;     se trouvant dans
;;     https://github.com/snape/RVO2
;;
;;
;;     Nous ne prétendons pas être être à l'origine de cet algorithme, nous servi du code existant et nous l'avons adapté a notre problème et le langage netlogo


;; 1- Calcule les lignes orca pour chaque agent dans le radius de vision, càd les agents qui représente possiblement une collision
;; 2- Résout un pblinéaire pour trouver la nouvelle vitesse qui respecte les contraintes orca et qui est proche de la vitesse preferee
;; 3- si l'etape precedente echoue, resout un pblineaire de dimension superieure 3
to compute_new_velocity_ORCA
  set orca_lines []

  let collision_neighbors_id []

  ask collision_neighbors[
    set collision_neighbors_id lput who collision_neighbors_id
  ]

  let inv_time_step (1 / time_step)

  foreach (collision_neighbors_id) [ agent_B_id ->

    let relativePosition list ( [xcor] of (robot agent_B_id) - xcor) ([ycor] of (robot agent_B_id) - ycor)

    let relativeVelocity (minus_vectors (velocity) ([velocity] of (robot agent_B_id)))

    let distSq abs_Sq relativePosition

    let combinedRadius robot_size + 2

    let combinedRadiusSq sqr combinedRadius

    let line list 0 0
    let u list 0 0


    ifelse (distSq > combinedRadiusSq)
    [
      ;;Pas de collision
      ;;Les agents ne se touchent pas

      let w (minus_vectors (relativeVelocity) (scale_vector relativePosition (inv_time_step)))

      let wLengthSq abs_Sq w

      let dp1 multiply_vectors w relativePosition

      ifelse(dp1 < 0 and sqr dp1 > (combinedRadiusSq * wLengthSq) )
      [
        let wLength sqrt wLengthSq
        let unitW scale_vector w ( 1 / wLength )

        ;;line.direction = Vector2(unitW.y(), -unitW.x());
        set line replace-item 1 line list ( item 1 unitW ) (- item 0 unitW )
        set u scale_vector unitW (combinedRadius * inv_time_step - wLength)

      ]
      [
        let leg sqrt (distSq - combinedRadiusSq)

        ifelse(det relativePosition w > 0)
        [
          ;;line.direction = Vector2(relativePosition.x() * leg - relativePosition.y() * combinedRadius, relativePosition.x() * combinedRadius + relativePosition.y() * leg) / distSq;
          let d_x item 0 relativePosition * leg - item 1 relativePosition * combinedRadius
          let d_y item 0 relativePosition * combinedRadius + item 1 relativePosition * leg

          set line replace-item 1 line (scale_vector (list (d_x) (d_y)) (1 / distSq))
        ]
        [
          ;;line.direction = -Vector2(relativePosition.x() * leg + relativePosition.y() * combinedRadius, -relativePosition.x() * combinedRadius + relativePosition.y() * leg) / distSq;
          let d_x item 0 relativePosition * leg + item 1 relativePosition * combinedRadius
          let d_y  (- (item 0 relativePosition)) * combinedRadius + item 1 relativePosition * leg

          set line replace-item 1 line scale_vector (list (d_x) (d_y)) (- 1 / distSq)
        ];;end_ifelse

        ;;dotProduct2 = relativeVelocity * line.direction;
        let dp2 multiply_vectors relativeVelocity item 1 line

        set u minus_vectors (scale_vector item 1 line dp2) (relativeVelocity)
      ];;end_ifelse
    ];;end_ifelse
    [
      ;;Collision. Project on cut-off circle of time timeStep. In our implementation 1
      let w (minus_vectors (relativeVelocity) (relativePosition))

      ;;let unitW normalize_vector w
      ;;normalisation?
      let wLenght abs_ w
      let unitW scale_vector w (1 / wLenght)


      ;;line.direction = Vector2(unitW.y(), -unitW.x());
      set line replace-item 1 line list (item 1 unitW) (- (item 0 unitW))

      set u (scale_vector (unitW) (combinedRadius - wLenght))
    ]

    ;;line.point = velocity_ + 0.5f * u;
    set line replace-item 0 line (add_vectors (velocity) (scale_vector u 0.5))
    set orca_lines lput line orca_lines

  ];;end_foreach

  let lineFail linearProgram2 orca_lines max_speed pref_velocity false

  if ( lineFail < length orca_lines )
  [
    linearProgram3 orca_lines 0 lineFail max_speed
  ]

  show_guidelines

end


;;affiche les vecteurs de vitesse et les lignes orca
to show_guideLines
  if (show_Orca_Lines)
  [
    let col random 140
    foreach (orca_lines) [line ->

      let point item 0 line
      let direction item 1 line

      let i lnk_id_cnt + 1
      let j lnk_id_cnt + 2
      set lnk_id_cnt lnk_id_cnt + 2

      ask patch-here [
        sprout-lnks 1 [
          setxy (xcor + (item 0 point)) (ycor + (item 1 point))
          set lnk_id i
          set size 0
          set col col + 2
          set color col
          set pen-size line_width
          pen-down
          let k 0
          let orca_vector normalize_vector list (xcor + (item 0 direction)) (ycor +(item 1 direction))
          setxy (xcor + (item 0 orca_vector) * (robot_size * 2 )) (ycor + (item 1 orca_vector) * (robot_size * 2))
          setxy (xcor + (item 0 orca_vector) * (- (robot_size * 4) )) (ycor + (item 1 orca_vector) * (- (robot_size * 4) ))
        ]
      ]
    ];;end_foreach
  ];;end_if

  if (show_velocity)
  [
    let velocity_vector new_velocity
    let i lnk_id_cnt + 1
    ask patch-here [
      sprout-lnks 1 [
        set lnk_id_cnt lnk_id_cnt + 1
        set size 0
        set lnk_id lnk_id_cnt
        setxy (xcor + (item 0 velocity_vector)) (ycor + (item 1 velocity_vector))
      ]
    ]
    create-red-link-to one-of lnks with [ lnk_id = i ] [
      set color green
      set thickness line_width
    ]
  ]

  if (show_detection_collision_range)
  [
    ask patches in-radius collision_detection_range [
      set pcolor [who] of myself
    ]
  ]

end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;██    ██ ███████  ██████ ████████  ██████  ██████       ██████  ██████  ███████ ██████   █████  ████████ ██  ██████  ███    ██ ███████
;;██    ██ ██      ██         ██    ██    ██ ██   ██     ██    ██ ██   ██ ██      ██   ██ ██   ██    ██    ██ ██    ██ ████   ██ ██
;;██    ██ █████   ██         ██    ██    ██ ██████      ██    ██ ██████  █████   ██████  ███████    ██    ██ ██    ██ ██ ██  ██ ███████
;; ██  ██  ██      ██         ██    ██    ██ ██   ██     ██    ██ ██      ██      ██   ██ ██   ██    ██    ██ ██    ██ ██  ██ ██      ██
;;  ████   ███████  ██████    ██     ██████  ██   ██      ██████  ██      ███████ ██   ██ ██   ██    ██    ██  ██████  ██   ████ ███████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; vec = list (x y)
;; line = list ( (vec) (vec) )
;; lines = list line line ...

;;carre
to-report sqr [k]
  report k * k
end

;;longueur vector carree
to-report abs_Sq [vec]
  let ret multiply_vectors vec vec
  report ret
end

;;longueur vector
to-report abs_ [vec]
  report sqrt ( abs_Sq vec )
end

;;determinant
to-report det [ vec1 vec2 ]
  let ret ( (item 0 vec1) * (item 1 vec2 ) - (item 1 vec1 ) * (item 0 vec2 ) )
  report ret
end

;;normalisation
to-report normalize_vector [ vec ]
  report scale_vector vec ( 1 / abs_ vec )
end

;;multiplication
to-report multiply_vectors [ vec1 vec2 ]
  report ( item 0 vec1 ) * ( item 0 vec2 ) + ( item 1 vec1 ) * ( item 1 vec2 )
end

;;scale
to-report scale_vector [ vec k ]
  report ( list (k * (item 0 vec )) (k * (item 1 vec )) )
end

;;substraction
to-report minus_vectors [ vec1 vec2 ]
  report list (( item 0 vec1 ) - ( item 0 vec2 ))  (( item 1 vec1 ) - ( item 1 vec2 ))
end

;;addition
to-report add_vectors [ vec1 vec2]
  report list (( item 0 vec1 ) + ( item 0 vec2 ))  (( item 1 vec1 ) + ( item 1 vec2 ))
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;██      ██ ███    ██ ███████  █████  ██████      ██████  ██████   ██████   ██████  ██████   █████  ███    ███
;;██      ██ ████   ██ ██      ██   ██ ██   ██     ██   ██ ██   ██ ██    ██ ██       ██   ██ ██   ██ ████  ████
;;██      ██ ██ ██  ██ █████   ███████ ██████      ██████  ██████  ██    ██ ██   ███ ██████  ███████ ██ ████ ██
;;██      ██ ██  ██ ██ ██      ██   ██ ██   ██     ██      ██   ██ ██    ██ ██    ██ ██   ██ ██   ██ ██  ██  ██
;;███████ ██ ██   ████ ███████ ██   ██ ██   ██     ██      ██   ██  ██████   ██████  ██   ██ ██   ██ ██      ██
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report linearProgram1 [ lines lineNo _radius optVelocity directionOpt ]

  let direction ( item 1 (item lineNo lines) )
  let point (item 0 (item lineNo lines) )


  let dp  multiply_vectors point direction

  let discriminant ( sqr ( dp ) + sqr ( _radius ) - abs_Sq ( point ) )

  if ( discriminant < 0 )
  [
    ;;Max speed circle fully invalidates line lineNo.
    report false
  ]

  let sqrtDiscriminant sqrt discriminant
  let t_left ( (- dp) - sqrtDiscriminant )
  let t_right ( (- dp) + sqrtDiscriminant )

  foreach (range lineNo) [ i ->

    let res (intermediaire1 t_left t_right (item i lines) direction point)

    ifelse(item 0 res)
    [
      set t_left item 1 res
      set t_right item 2 res
    ]
    [
      if(item 1 res = 0) [report false]
    ]

  ];;end_foreach


  ifelse ( directionOpt )
  [
    ;;Optimize direction.
    ifelse  ( multiply_vectors  optVelocity  direction > 0  )
    [
      ;;Take right extreme.
      ;;new_velocity = lines[lineNo].point + (tRight * lines[lineNo].direction;)
      set new_velocity add_vectors (scale_vector direction t_right ) (point)
    ]
    [
      ;;Take left extreme.
      set new_velocity add_vectors (scale_vector direction t_left ) (point)
    ]
  ]
  [
    ;;Optimize closest point
    ;;lines[lineNo].direction * (optVelocity - lines[lineNo].point);
    let t multiply_vectors (direction) (minus_vectors optVelocity point)

    ifelse ( t < t_left)
    [
      ;;new_velocity = lines[lineNo].point + tLeft * lines[lineNo].direction;
      set new_velocity add_vectors (scale_vector direction t_left ) (point)
    ]
    [
     ifelse( t > t_right)
      [
        set new_velocity add_vectors (scale_vector direction t_right ) (point)
      ]
      [;;t=t_left=t_right
        set new_velocity add_vectors (scale_vector direction t_right ) (point)
      ];;end_ifelse
    ];;end_ifelse
  ];;end_ifelse
  report true
end


to-report intermediaire1 [tl tr line direction point]
  let t_left tl
  let t_right tr
  let direction_i ( item 1 line)
  let point_i ( item 0 line)

  ;;det(lines[lineNo].direction, lines[i].direction);
  let denominator ( det  direction  direction_i )
  ;;det(lines[i].direction, lines[lineNo].point - lines[i].point);
  let numerator ( det ( direction_i ) ( minus_vectors point point_i  ) )

  if ( abs ( denominator ) <= 0.000000001 )
  [
    ;;Lines lineNo and i are (almost) parallel.
    ifelse ( numerator < 0 )
    [
      report list false 0
    ]
    [
      report list false 1
    ]
  ]

  let t ( numerator / denominator )

  ifelse ( denominator >= 0 )
  [
    ;;Line i bounds line lineNo on the right.
    set t_right ( min (list t_right t) )

  ]
  [
    ;;Line i bounds line lineNo on the left.
    set t_left ( max (list t_left t) )

  ];;end_ifelse

  if (t_left > t_right) [ report list false 0 ]

  report (list (true) (t_left) (t_right))

end




to-report linearProgram2 [ lines _radius optVelocity directionOpt]

  ifelse ( directionOpt )
  [set new_velocity scale_vector optVelocity _radius]
  [
    ifelse ( abs_Sq optVelocity > sqrt _radius)
    [set new_velocity scale_vector normalize_vector optVelocity _radius]
    [set new_velocity optVelocity]
  ]

  foreach (range length lines) [ lineNo ->
    let direction ( item 1 (item lineNo lines) )
    let point (item 0 (item lineNo lines) )
    if (det direction minus_vectors point new_velocity  > 0)
    [
      ;;new_velocity does not satisfy constraint i. Compute new optimal new_velocity.
      let tmpnew_velocity new_velocity
      let lp1 linearProgram1 lines lineNo _radius optVelocity directionOpt
      if (not lp1)
      [
        set new_velocity tmpnew_velocity
        report lineNo
      ]
    ]
  ]

  report (length lines)
end


to linearProgram3 [ lines numObstLines beginLine _radius]

  let dist 0

  foreach (range beginLine (length lines)) [ lineNo ->

   let direction ( item 1 (item lineNo lines) )
   let point (item 0 (item lineNo lines) )

   ;;if (det(lines[i].direction, lines[i].point - new_velocity) > distance)
   if ( (det (direction) (minus_vectors (point) (new_velocity)) ) > dist )
   [
      ;;new_velocity does not satisfy constraint of line i.
      let projLines []
      foreach (range 0 numObstLines) [ i ->
        set projLines lput item i lines projLines

      ]

      foreach (range numObstLines (lineNo)) [ j ->

        let line []
        let direction_j ( item 1 (item j lines) )
        let point_j (item 0 (item j lines) )

        let determinant det direction direction_j

        ifelse  (abs determinant <= 0.0000001)
        [
          ;;Line i and line j are parallel.
          ifelse( (multiply_vectors direction direction_j) > 0)
          [
            ;;Line i and line j point in the same direction.
            ;;continue
          ]
          [
            ;;Line i and line j point in opposite direction.
            ;;line.point = 0.5f * (lines[i].point + lines[j].point);
            set line lput (scale_vector (add_vectors point point_j) 0.5) line
          ];;end_ifelse
        ]
        [
          ;;line.point = lines[i].point + (det(lines[j].direction, lines[i].point - lines[j].point) / determinant) * lines[i].direction;
          ;; p = a + b
          let m minus_vectors point point_j
          let d det direction_j m
          let b scale_vector direction ( d / determinant )
          let p add_vectors point b
          set line lput p line
        ];;end_ifelse


          set line lput ( normalize_vector (minus_vectors direction_j direction) ) line
          set projLines lput line projLines

      ] ;;end_foreach

      let tmpnew_velocity new_velocity

      ;;linearProgram2(projLines, radius, Vector2(-lines[i].direction.y(), lines[i].direction.x()), true)
      let optVelocity_ list (- (item 1 direction) ) (item 0 direction)
      let lp2 linearProgram2 projLines _radius optVelocity_ true
      if (lp2 < length projLines) [set new_velocity tmpnew_velocity]

    set dist (det (direction) (minus_vectors point new_velocity))
    ]

  ]
end

;;============================================================================================================
;;============================================================================================================
;;============================================================================================================

;; Ici nous avons commence a coder la triangulation de delaunay (duale de la partion de voronoi)
;; pour permettre une autre approche a voronoi tesselation, nous n'avons pas le temps de finir càd
;; imposer des contraintes pour des pattens non convex

;;https://stackoverflow.com/questions/39984709/how-can-i-check-wether-a-point-is-inside-the-circumcircle-of-3-points
;;https://www.wikiwand.com/en/Delaunay_triangulation
;;returns true if triangle is ccw
to-report ccw [ax ay bx by cx cy]
   report (bx - ax) * (cy - ay)-(cx - ax) * (by - ay) > 0
end

;; returns true if x y inside circumcircle of abc
to-report inCircle [ax ay bx by cx cy x y]
    let ax_  ax - x;
    let ay_  ay - y;
    let bx_  bx - x;
    let by_  by - y;
    let cx_  cx - x;
    let cy_  cy - y;
    report (
        (ax_ * ax_ + ay_ * ay_) * (bx_ * cy_ - cx_ * by_) -
        (bx_ * bx_ + by_ * by_) * (ax_ * cy_ - cx_ * ay_) +
        (cx_ * cx_ + cy_ * cy_) * (ax_ * by_ - bx_ * ay_)
    ) > 0
end

;;https://www.wikiwand.com/en/Bowyer%E2%80%93Watson_algorithm
to delaunay_triangulation [pattern_id]
  let points particules with [particule_pattern = pattern_id]
  let verts_x [-1000 0 1000]
  let verts_y [-1000 1000 -1000]
  let triangles [ [0 2 1] ]


  ask points
  [
    let edges []
    let incorrect_triangles []

    ;;for each triangle
    foreach triangles[ triangle ->
      ;;if point within circumcircle
      if ( inCircle
        (item (item 0 triangle) verts_x)
        (item (item 0 triangle) verts_y)
        (item (item 1 triangle) verts_x)
        (item (item 1 triangle) verts_y)
        (item (item 2 triangle) verts_x)
        (item (item 2 triangle) verts_y)
        (xcor) (ycor)
        )
      [
        ;;set triangle as incorrect
        set incorrect_triangles lput triangle incorrect_triangles
      ]
    ]

    ;; for each incorrect triangle t, for each edge in t if edge is not shared by any other incorrect triangle add edge to edges
    foreach incorrect_triangles [ t ->

      let others remove t incorrect_triangles
      let e1 list (item 0 t) (item 1 t)
      let e2 list (item 0 t) (item 2 t)
      let e3 list (item 1 t) (item 2 t)

      let add_e1 true
      let add_e2 true
      let add_e3 true

      foreach others [ other_t ->
        if member? item 0 e1 other_t and member? item 1 e1 other_t
        [
          set add_e1 false
        ]
        if member? item 0 e2 other_t and member? item 1 e2 other_t
        [
          set add_e2 false
        ]
        if member? item 0 e3 other_t and member? item 1 e3 other_t
        [
          set add_e3 false
        ]
      ]
      if add_e1 [ set edges lput e1 edges ]
      if add_e2 [ set edges lput e2 edges ]
      if add_e3 [ set edges lput e3 edges ]
    ]


    ;; remove incorrect triangles
    foreach incorrect_triangles [ t ->
      set triangles remove t triangles
    ]

    set verts_x lput xcor verts_x
    set verts_y lput ycor verts_y
    let l ( ( length verts_x ) - 1 )
    let new_triangle []

    ;; build triangles
    while [ not empty? edges]
    [
      let edge first edges
      set edges but-first edges

      ;; construct new counter clock wise triangle
      ifelse ccw (item (item 0 edge) verts_x) (item (item 0 edge) verts_y) (item (item 1 edge) verts_x) (item (item 1 edge) verts_y) xcor ycor
      [
        set new_triangle ( list (item 0 edge) (item 1 edge) l)
      ]
      [
        set new_triangle ( list (item 0 edge) l (item 1 edge))
      ]
      ;; add new triangle
      set triangles lput new_triangle triangles
    ]
  ]

  ;; for each triangl if triangle contains vertex from super triangle remove triangle
  foreach triangles [ t ->
    ;; super triangle [0 2 1]
    if (
      item 0 t = 0 or item 1 t = 0 or item 2 t = 0
      or
      item 0 t = 2 or item 1 t = 2 or item 2 t = 2
      or
      item 0 t = 1 or item 1 t = 1 or item 2 t = 1
    )
    [
      set triangles remove t triangles
    ]
  ]

  create-turtles 1
  [
    foreach triangles [ t ->
      set color ( color + 15 )
      setxy item (item 0 t) verts_x item (item 0 t) verts_y
      pen-down
      setxy item (item 1 t) verts_x item (item 1 t) verts_y
      setxy item (item 2 t) verts_x item (item 2 t) verts_y
      setxy item (item 0 t) verts_x item (item 0 t) verts_y
      pen-up
    ]
  ]
end

to test
  foreach patterns_colors [ c ->
    delaunay_triangulation c
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
475
10
984
520
-1
-1
1.0
1
10
1
1
1
0
1
1
1
-250
250
-250
250
1
1
1
ticks
30.0

SLIDER
34
73
389
106
number_of_robots
number_of_robots
1
150
10.0
1
1
NIL
HORIZONTAL

BUTTON
32
261
384
294
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

SLIDER
1006
135
1458
168
pattern_percentage
pattern_percentage
0.01
0.1
0.01
0.005
1
NIL
HORIZONTAL

SWITCH
1011
205
1237
238
show_particules
show_particules
1
1
-1000

SWITCH
1240
205
1460
238
show_partitions
show_partitions
1
1
-1000

MONITOR
1006
36
1456
81
NIL
patterns_colors
17
1
11

MONITOR
1006
84
1458
129
NIL
patterns_weights
3
1
11

SLIDER
1011
248
1459
281
max_Voronoi_Tesselation_iterations
max_Voronoi_Tesselation_iterations
1
35
17.0
1
1
NIL
HORIZONTAL

SLIDER
1011
288
1459
321
tessellation_convergence_goal
tessellation_convergence_goal
0
2
0.95
0.05
1
NIL
HORIZONTAL

BUTTON
1396
529
1459
562
NIL
test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
32
209
205
254
defaul_pattern
defaul_pattern
"triangle" "rectangle" "circle" "ring" "stars" "2Lines" "gradientShapes" "falling_arrows" "flag" "flag1" "Google" "Stack_Overflow" "discord" "robot" "flame" "cyclops"
0

BUTTON
209
210
385
255
NIL
setup_default
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
31
118
386
204
11

SLIDER
34
34
389
67
robot_size
robot_size
3
30
30.0
1
1
NIL
HORIZONTAL

BUTTON
33
300
384
333
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

SLIDER
29
372
382
405
max_speed
max_speed
0
10
2.5
0.1
1
NIL
HORIZONTAL

SLIDER
29
413
380
446
collision_detection_range
collision_detection_range
5
100
51.0
1
1
NIL
HORIZONTAL

SWITCH
1014
388
1227
421
show_velocity
show_velocity
1
1
-1000

SWITCH
1235
388
1458
421
show_ORCA_lines
show_ORCA_lines
1
1
-1000

SLIDER
1237
429
1458
462
line_width
line_width
1
10
3.0
0.2
1
NIL
HORIZONTAL

SLIDER
29
456
380
489
k_a_controller
k_a_controller
1
30
15.0
1
1
NIL
HORIZONTAL

SWITCH
1280
529
1392
562
show_grid
show_grid
0
1
-1000

SLIDER
29
500
381
533
time_step
time_step
1
10
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
1013
355
1456
384
This model is tick based.\nTo show velocity vector or orcalines change update type from \"on ticks\" to \"continuous\".\n
11
0.0
1

TEXTBOX
1007
10
1157
35
Patterns
20
0.0
1

TEXTBOX
1010
174
1325
224
Voronoi Tesselation
20
0.0
1

TEXTBOX
1013
331
1163
356
ORCA_display
20
0.0
1

TEXTBOX
32
342
182
367
ORCA_PARAMS
20
0.0
1

SWITCH
1013
428
1227
461
show_detection_collision_range
show_detection_collision_range
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

circle 3
false
1
Circle -2674135 false true 0 0 300
Circle -2674135 false true 90 90 120

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
NetLogo 6.2.2
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
