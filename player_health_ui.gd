extends HBoxContainer

# Ces variables apparaîtront dans l'Inspecteur pour y glisser vos images
@export var texture_pv_plein: Texture2D
@export var texture_pv_vide: Texture2D

var max_pv: int = 3	
var pv: int = 3

# Appelez cette fonction quand le joueur prend des dégâts ou se soigne
func set_pv(remainingPv: int):
	# On s'assure que les PV restent entre 0 et 3
	pv = clamp(remainingPv, 0, max_pv)
	updateUI()

func updateUI():
	# get_children() récupère nos 3 TextureRect (HP1, HP2, HP3)
	var icones_pv = get_children()
	
	for i in range(icones_pv.size()):
		# Si l'index de l'icône est inférieur aux PV actuels, on affiche l'image "plein"
		if i < pv:
			icones_pv[i].texture = texture_pv_plein
		# Sinon, on affiche l'image "vide" (détruit)
		else:
			icones_pv[i].texture = texture_pv_vide

# Fonction appelée au lancement pour initialiser l'affichage
func _ready():
	updateUI()
