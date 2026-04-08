:- module(faults, [
    fault/1,
    symptom/2,
    recommendation/2,
    question_text/2
]).

% Each fact below names a possible diagnosis the system can test.
fault(dead_battery).
fault(bad_alternator).
fault(starter_failure).
fault(spark_plug_issue).
fault(overheating_engine).

% symptom(Fault, Symptom) defines which symptoms support each diagnosis.
symptom(dead_battery, engine_wont_start).
symptom(dead_battery, lights_dim).
symptom(dead_battery, clicking_sound).

symptom(bad_alternator, battery_warning_light).
symptom(bad_alternator, lights_dim).
symptom(bad_alternator, engine_stalls).

symptom(starter_failure, engine_wont_start).
symptom(starter_failure, dashboard_lights_on).
symptom(starter_failure, single_click).

symptom(spark_plug_issue, engine_misfire).
symptom(spark_plug_issue, rough_idle).
symptom(spark_plug_issue, poor_fuel_economy).

symptom(overheating_engine, temperature_gauge_high).
symptom(overheating_engine, steam_from_hood).
symptom(overheating_engine, coolant_leak).

% recommendation(Fault, Advice) stores the repair guidance for each diagnosis.
recommendation(dead_battery, 'Check battery charge, terminals, and consider a jump start or replacement.').
recommendation(bad_alternator, 'Inspect the alternator and charging system output.').
recommendation(starter_failure, 'Test the starter motor, solenoid, and related wiring.').
recommendation(spark_plug_issue, 'Inspect and replace worn spark plugs if needed.').
recommendation(overheating_engine, 'Check coolant level, radiator, thermostat, and water pump.').

% question_text(Symptom, Prompt) maps each symptom to a user-friendly question.
question_text(engine_wont_start, 'Does the engine fail to start?').
question_text(lights_dim, 'Are the headlights or dashboard lights dim?').
question_text(clicking_sound, 'Do you hear repeated clicking when turning the key?').
question_text(battery_warning_light, 'Is the battery warning light on?').
question_text(engine_stalls, 'Does the engine stall while running?').
question_text(dashboard_lights_on, 'Do the dashboard lights turn on normally?').
question_text(single_click, 'Do you hear a single click when trying to start the car?').
question_text(engine_misfire, 'Is the engine misfiring?').
question_text(rough_idle, 'Does the car idle roughly?').
question_text(poor_fuel_economy, 'Have you noticed poor fuel economy?').
question_text(temperature_gauge_high, 'Is the temperature gauge reading high?').
question_text(steam_from_hood, 'Is steam coming from under the hood?').
question_text(coolant_leak, 'Do you see signs of a coolant leak?').
