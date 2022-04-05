globals
[
  ;;PATTERNS;;
  patterns_colors       ;; id/color defining a pattern
  patterns_weights      ;; ratio of pattern among all patterns
]
patches-own
[
  patch_pattern         ;; pattern id/color associated whit this patch
  patch_partition       ;; partition associated with this patch
]
breed [particules particule]
breed [robots robot]
particules-own
[
  particule_pattern
  particule_partition    ;; partition associated with this particule
]
robots-own
[
  max_speed
]
;; import pattern
;; gen points a l'interieur de pattern
;; voronoi partitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ███████ ███████ ████████ ██    ██ ██████
;; ██      ██         ██    ██    ██ ██   ██
;; ███████ █████      ██    ██    ██ ██████
;;      ██ ██         ██    ██    ██ ██
;; ███████ ███████    ██     ██████  ██
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup_default
  clear-all
  output-print "--SETUP STARTED--"
  initContext
  importDefaultPatterns
  generateGoals
  generate_robots
  output-print "--SETUP ENDED--"
end
to setup
  clear-all
  output-print "--SETUP STARTED--"
  initContext
  importPatterns
  generateGoals
  generate_robots
  output-print "--SETUP ENDED--"
end

to initContext
  set patterns_colors []
  set patterns_weights []
  set-default-shape particules "x"
  set-default-shape robots "circle 3"
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

;; spawns a particule on patch
to create_particule [ id ]
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

;; calculate partition
to calculate_partitions
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

to create_robot
  sprout-robots 1 [
    set size robot_size
    set color [color] of (particule (who - number_of_robots ))
  ]
end

to generate_robots
  ask n-of number_of_robots patches [create_robot]
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
  ask robots [ move_to_goal ]
end






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ████████ ██    ██ ██████  ████████ ██      ███████ ███████
;;    ██    ██    ██ ██   ██    ██    ██      ██      ██
;;    ██    ██    ██ ██████     ██    ██      █████   ███████
;;    ██    ██    ██ ██   ██    ██    ██      ██           ██
;;    ██     ██████  ██   ██    ██    ███████ ███████ ███████
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move_to_goal
  face ( particule (who - number_of_robots ) )
  fd 0.01
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

;;Pattern est defini
;;  - pattern_color
;;  - partitions
to importPatterns
  ask patches [
    set pcolor white
  ]
  ;; import image and paint patches
  import-pcolors user-file
end

to importDefaultPatterns
  ask patches [
    set pcolor white
  ]
  let file word (word "DefaultPatterns/" defaul_pattern) ".png"
  ;; import image and paint patches
  import-pcolors file
end

;; imports file, creates patterns and paints patches accordingly
to createPatterns
  ;; fill patterns data (color, ratio)
  ask patches [
    ;; link patch to pattern
    set patch_pattern pcolor
    ;; if patch color not in patterns_colors add, else increment
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
  ;; output from import-pcolors file has some noise so we clean the results
  ;; drop 'fake patterns': from last index to 0 at -1 pace
  foreach (range (length patterns_weights - 1) -1 -1) [ x -> drop_pattern x pattern_percentage ]
  ;;update ratio
  let total_ratio sum patterns_weights
  set patterns_weights map [x -> precision (x / total_ratio) 2] patterns_weights
  ;;clear noise: patches wich are not white and not associated with pattern
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

;;drops pattern x if ratio < percentage
to drop_pattern [x percentage]
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

;; calculates number_of_particules (robots) associated with pattern from ratio
to-report calcul_number_of_particules
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

;; generates number_of_particules particules starting from id to id+number_of_particules on pattern p
to pattern_generate_particules [number_of_particules p id]
  ask n-of number_of_particules patches with [patch_pattern = p]
  [
    create_particule id
    set id (id + 1)
  ]
end

;; genretes particlues for each pattern
to generate_particules
  ;; start particules id at 0
  let particules_index 0
  let number_of_particules calcul_number_of_particules
  ;; for each pattern calculate required number of particules and generate particules
  foreach (range length patterns_weights) [ id ->
    pattern_generate_particules (item id number_of_particules) (item id patterns_colors) (particules_index)
    set particules_index (particules_index + (item id number_of_particules))
  ]
end

;;calculates centroid for all partitions. note: number of partitions = number of robots
to-report calculateCentroids
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

to voronoi_tesselation
  ask patches [calculate_partitions]
  let voronoi_iteration 0
  while [calculateCentroids  and voronoi_iteration <= max_Voronoi_Tesselation_iterations]
  [
    output-print word (word "___Voronoi_tesselation: runnig iteration " voronoi_iteration) "..."
    ask patches [calculate_partitions]
    set voronoi_iteration (voronoi_iteration + 1)
  ]
end

to generateGoals
  createPatterns
  generate_particules
  voronoi_tesselation
  reset-ticks
end

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
1034
570
-1
-1
1.0
1
10
1
1
1
0
0
0
1
-275
275
-275
275
0
0
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
0
250
110.0
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
1043
110
1215
143
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
1044
153
1188
186
show_particules
show_particules
1
1
-1000

SWITCH
1191
153
1334
186
show_partitions
show_partitions
0
1
-1000

MONITOR
1043
10
1507
55
NIL
patterns_colors
17
1
11

MONITOR
1043
58
1508
103
NIL
patterns_weights
3
1
11

SLIDER
1045
234
1294
267
max_Voronoi_Tesselation_iterations
max_Voronoi_Tesselation_iterations
1
35
22.0
1
1
NIL
HORIZONTAL

SLIDER
1045
274
1295
307
tessellation_convergence_goal
tessellation_convergence_goal
0
2
0.35
0.05
1
NIL
HORIZONTAL

BUTTON
77
340
140
373
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
12

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
206
67
robot_size
robot_size
3
20
11.0
1
1
NIL
HORIZONTAL

BUTTON
151
340
214
373
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
