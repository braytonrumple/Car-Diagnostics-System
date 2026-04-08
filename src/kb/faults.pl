:- module(faults, [
    fault/1,
    fault_name/2,
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
fault(fuel_pump_failure).
fault(clogged_air_filter).
fault(low_oil_pressure).
fault(radiator_fan_failure).
fault(blown_ignition_fuse).

% fault_name(Fault, Name) stores a user-friendly name for each diagnosis.
fault_name(dead_battery, 'Dead Battery').
fault_name(bad_alternator, 'Bad Alternator').
fault_name(starter_failure, 'Starter Failure').
fault_name(spark_plug_issue, 'Spark Plug Issue').
fault_name(overheating_engine, 'Overheating Engine').
fault_name(fuel_pump_failure, 'Fuel Pump Failure').
fault_name(clogged_air_filter, 'Clogged Air Filter').
fault_name(low_oil_pressure, 'Low Oil Pressure').
fault_name(radiator_fan_failure, 'Radiator Fan Failure').
fault_name(blown_ignition_fuse, 'Blown Ignition Fuse').

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

symptom(fuel_pump_failure, engine_cranks_but_wont_start).
symptom(fuel_pump_failure, fuel_whine_absent).
symptom(fuel_pump_failure, loss_of_power).

symptom(clogged_air_filter, poor_acceleration).
symptom(clogged_air_filter, poor_fuel_economy).
symptom(clogged_air_filter, dirty_air_filter).

symptom(low_oil_pressure, oil_warning_light).
symptom(low_oil_pressure, engine_knocking).
symptom(low_oil_pressure, low_oil_level).

symptom(radiator_fan_failure, temperature_gauge_high).
symptom(radiator_fan_failure, engine_hot_at_idle).
symptom(radiator_fan_failure, cooling_fan_not_running).

symptom(blown_ignition_fuse, engine_wont_start).
symptom(blown_ignition_fuse, no_dashboard_power).
symptom(blown_ignition_fuse, electrical_accessories_off).

% recommendation(Fault, Advice) stores the repair guidance for each diagnosis.
recommendation(dead_battery, 'Check battery charge, terminals, and consider a jump start or replacement.').
recommendation(bad_alternator, 'Inspect the alternator and charging system output.').
recommendation(starter_failure, 'Test the starter motor, solenoid, and related wiring.').
recommendation(spark_plug_issue, 'Inspect and replace worn spark plugs if needed.').
recommendation(overheating_engine, 'Check coolant level, radiator, thermostat, and water pump.').
recommendation(fuel_pump_failure, 'Inspect the fuel pump, fuel pressure, and fuel filter.').
recommendation(clogged_air_filter, 'Inspect the air filter and replace it if it is dirty or blocked.').
recommendation(low_oil_pressure, 'Check the oil level immediately and inspect for leaks or oil pump issues.').
recommendation(radiator_fan_failure, 'Inspect the radiator fan motor, relay, and temperature sensor.').
recommendation(blown_ignition_fuse, 'Inspect the ignition fuse and related electrical circuits for shorts.').

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
question_text(engine_cranks_but_wont_start, 'Does the engine crank but still fail to start?').
question_text(fuel_whine_absent, 'Do you no longer hear the fuel pump priming sound from the fuel tank area?').
question_text(loss_of_power, 'Does the vehicle lose power while driving?').
question_text(poor_acceleration, 'Does the vehicle have poor acceleration?').
question_text(dirty_air_filter, 'Is the air filter visibly dirty or clogged?').
question_text(oil_warning_light, 'Is the oil pressure warning light on?').
question_text(engine_knocking, 'Do you hear a knocking sound from the engine?').
question_text(low_oil_level, 'Is the engine oil level low?').
question_text(engine_hot_at_idle, 'Does the engine run especially hot while idling?').
question_text(cooling_fan_not_running, 'Is the cooling fan not turning on when the engine gets hot?').
question_text(no_dashboard_power, 'Is there no power on the dashboard when you turn the key?').
question_text(electrical_accessories_off, 'Are electrical accessories staying off when the ignition is on?').
