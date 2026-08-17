# player_stats.gd (autoload, name it "PlayerStats")
extends Node

func recalculate() -> Dictionary:
    var all_modifiers: Array[StatModifier] = []
    all_modifiers.append_array(MetaProgression.get_all_modifiers())
    all_modifiers.append_array(RunUpgrades.active_modifiers)

    var flat_totals: Dictionary = {}     # stat_name -> summed flat bonus
    var percent_totals: Dictionary = {}  # stat_name -> summed percent bonus

    for mod in all_modifiers:
        if mod.modifier_type == StatModifier.ModifierType.FLAT:
            flat_totals[mod.stat_name] = flat_totals.get(mod.stat_name, 0.0) + mod.value
        else:
            percent_totals[mod.stat_name] = percent_totals.get(mod.stat_name, 0.0) + mod.value

    return {"flat": flat_totals, "percent": percent_totals}

var _cached_totals: Dictionary = {}

func refresh() -> void:
    _cached_totals = recalculate()

func apply_to(stat_name: String, base_value: float) -> float:
    var flat: float = _cached_totals.get("flat", {}).get(stat_name, 0.0)
    var percent: float = _cached_totals.get("percent", {}).get(stat_name, 0.0)
    return (base_value + flat) * (1.0 + percent)