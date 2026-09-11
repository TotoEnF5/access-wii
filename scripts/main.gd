extends Node

@export var min_time: float = 1.0
@export var max_time: float = 3.0
@export var temps_de_clash: float = 0.08 

# --- VOS SCÈNES D'ANIMATION (.tscn) ---
@export var scene_anim_j1: PackedScene    
@export var scene_anim_j2: PackedScene    
@export var scene_anim_clash: PackedScene 

@onready var _timer = $Timer
@onready var _timer2 = $Timer2

@onready var ui_joueur1 = $Camera2D/UI_Joueur1
@onready var ui_joueur2 = $Camera2D/UI_Joueur2

@onready var conteneur_animations = $ConteneurAnimations 
@onready var label_signal = $Label # NOUVEAU : Référence au texte

# --- SONS ---
@onready var bgm = $BGM             
@onready var sfx_signal = $SFX_Signal
@onready var sfx_slash = $SFX_Slash 
@onready var sfx_defaite = $SFX_Defaite 
@onready var sfx_clash = $SFX_Clash   
@onready var sfx_victoire = $SFX_Victoire

var _waiting_for_input: bool = false
var _game_over: bool = false

var _is_resolving_input: bool = false
var _clash_happened: bool = false
var _first_attacker: int = 0

var pv_j1: int = 3
var pv_j2: int = 3

var animation_actuelle: Node = null 

func _ready() -> void:
	bgm.call_deferred("play")
	_timer.timeout.connect(_on_timer_timeout)
	_timer2.timeout.connect(_on_timer_2_timeout)
	pv_j1 = 3
	pv_j2 = 3
	ui_joueur1.call_deferred("set_pv", pv_j1)
	ui_joueur2.call_deferred("set_pv", pv_j2)
	_reset()

func _input(event: InputEvent) -> void:
	if not _waiting_for_input or _game_over:
		return

	if event.is_action_pressed("player1_slash"):
		_tenter_coup(1)
	elif event.is_action_pressed("player2_slash"):
		_tenter_coup(2)

func _tenter_coup(joueur_id: int) -> void:
	if not _is_resolving_input:
		_is_resolving_input = true
		_first_attacker = joueur_id
		
		await get_tree().create_timer(temps_de_clash).timeout
		
		_waiting_for_input = false 
		
		if _clash_happened:
			_resoudre_clash()
		else:
			_resoudre_round(_first_attacker)
			
	else:
		if joueur_id != _first_attacker:
			_clash_happened = true

# --- FONCTION POUR AFFICHER ET GÉRER L'ANIMATION ---
func _jouer_animation(scene_a_instancier: PackedScene) -> void:
	# 1. Nettoyage de sécurité
	if animation_actuelle != null and is_instance_valid(animation_actuelle):
		animation_actuelle.queue_free()
		
	# 2. Instanciation
	if scene_a_instancier != null:
		animation_actuelle = scene_a_instancier.instantiate()
		conteneur_animations.add_child(animation_actuelle)
		animation_actuelle.play()
		
		# 3. Connexion dynamique : quand l'animation est finie, on la détruit
		if animation_actuelle.has_signal("animation_finished"):
			animation_actuelle.animation_finished.connect(_on_animation_finished)

# Nouvelle fonction appelée automatiquement à la fin de l'animation
func _on_animation_finished() -> void:
	if animation_actuelle != null and is_instance_valid(animation_actuelle):
		animation_actuelle.queue_free()
		animation_actuelle = null

func _resoudre_clash() -> void:
	label_signal.text = "" # On cache le texte de signal
	_jouer_animation(scene_anim_clash) 
	sfx_clash.play() 
	_timer2.start()

func _resoudre_round(gagnant_du_round: int) -> void:
	label_signal.text = "" # On cache le texte de signal
	sfx_slash.play()  
	sfx_defaite.play()

	if gagnant_du_round == 1:
		_jouer_animation(scene_anim_j1) 
		pv_j2 -= 1
		ui_joueur2.set_pv(pv_j2)
	else:
		_jouer_animation(scene_anim_j2) 
		pv_j1 -= 1
		ui_joueur1.set_pv(pv_j1)
	
	_verifier_fin_de_partie()

func _verifier_fin_de_partie() -> void:
	if pv_j1 <= 0 or pv_j2 <= 0:
		_game_over = true
		sfx_victoire.play()
	else:
		_timer2.start()

func _reset() -> void:
	if _game_over:
		return 
		
	# Sécurité supplémentaire au cas où l'animation n'aurait pas eu le temps de finir
	if animation_actuelle != null and is_instance_valid(animation_actuelle):
		animation_actuelle.queue_free()
		animation_actuelle = null
		
	_waiting_for_input = false
	_is_resolving_input = false
	_clash_happened = false
	_first_attacker = 0
	
	label_signal.text = "" # On s'assure que le texte est vide pendant l'attente
	
	_timer.wait_time = randf_range(min_time, max_time)
	_timer.start()

func _on_timer_timeout() -> void:
	_waiting_for_input = true
	label_signal.text = "vibration !!" # Le texte apparaît pile au bon moment !
	sfx_signal.play() 

func _on_timer_2_timeout() -> void:
	_reset()
