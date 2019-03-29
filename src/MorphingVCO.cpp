#include "Modulators.hpp"


struct MorphingVCO : Module {
	enum ParamIds {
		PITCH_PARAM,
        RHO_PARAM,
        DELTA_PARAM,
		NUM_PARAMS
	};
	enum InputIds {
		PITCH_INPUT,
        RHO_INPUT,
        DELTA_INPUT,
		NUM_INPUTS
	};
	enum OutputIds {
		SIGNAL_OUTPUT,
		NUM_OUTPUTS
	};
	enum LightIds {
		BLINK_LIGHT,
		NUM_LIGHTS
	};

	float phase = 0.0;
	float blinkPhase = 0.0;
    int steps = 0;
    bool latch = false;

	MorphingVCO() : Module(NUM_PARAMS, NUM_INPUTS, NUM_OUTPUTS, NUM_LIGHTS) {}
	void step() override;

	// For more advanced Module features, read Rack's engine.hpp header file
	// - toJson, fromJson: serialization of internal data
	// - onSampleRateChange: event triggered by a change of sample rate
	// - onReset, onRandomize, onCreate, onDelete: implements special behavior when user clicks these from the context menu
};


void MorphingVCO::step() {
	// Implement a simple sine oscillator
	float deltaTime = engineGetSampleTime();

	// Compute the frequency from the pitch parameter and input
	float pitch = params[PITCH_PARAM].value;
	pitch += inputs[PITCH_INPUT].value;
	pitch = clamp(pitch, -4.0f, 4.0f);
	// The default pitch is C4
	float freq = 261.626f * powf(2.0f, pitch);
    
    // Accumylate the steps
    steps += 1;
    if (steps >= (1.0f / deltaTime) / freq)
        steps = 0;
    // Set the half-cycle period
    int cyclePeriod = ((1.0f / deltaTime) / freq) * 0.5;

	// Accumulate the phase
	phase += freq * deltaTime;
	if (phase >= 1.0f)
		phase -= 1.0f;

	// Compute the sine output
	float sine = sinf(2.0f * M_PI * phase);
    
    float square = (phase < cyclePeriod) ? 1.0f : 0.0f;
//    if (phase <= cyclePeriod)
//        float square = 0.0f;
//    else
//        float square = 1.0f;
    
	outputs[SIGNAL_OUTPUT].value = 5.0f * sine;

	// Blink light at 1Hz
	blinkPhase += deltaTime;
	if (blinkPhase >= 1.0f)
		blinkPhase -= 1.0f;
	lights[BLINK_LIGHT].value = (blinkPhase < 0.5f) ? 1.0f : 0.0f;
}


struct MorphingVCOWidget : ModuleWidget {
	MorphingVCOWidget(MorphingVCO *module) : ModuleWidget(module) {
		setPanel(SVG::load(assetPlugin(plugin, "res/MorphingVCO.svg")));

		addChild(Widget::create<ScrewSilver>(Vec(RACK_GRID_WIDTH, 0)));
		addChild(Widget::create<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, 0)));
		addChild(Widget::create<ScrewSilver>(Vec(RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));
		addChild(Widget::create<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));
        
        addParam(ParamWidget::create<Davies1900hBlackKnob>(Vec(76, 134), module, MorphingVCO::RHO_PARAM, -3.0, 3.0, 0.0));
		addParam(ParamWidget::create<Davies1900hBlackKnob>(Vec(76, 263), module, MorphingVCO::PITCH_PARAM, -3.0, 3.0, 0.0));

		addInput(Port::create<PJ301MPort>(Vec(27, 315), Port::INPUT, module, MorphingVCO::PITCH_INPUT));
        addInput(Port::create<PJ301MPort>(Vec(27, 56), Port::INPUT, module, MorphingVCO::RHO_INPUT));
        addInput(Port::create<PJ301MPort>(Vec(133, 56), Port::INPUT, module, MorphingVCO::DELTA_INPUT));
		addOutput(Port::create<PJ301MPort>(Vec(133, 315), Port::OUTPUT, module, MorphingVCO::SIGNAL_OUTPUT));

		addChild(ModuleLightWidget::create<MediumLight<RedLight>>(Vec(89, 120), module, MorphingVCO::BLINK_LIGHT));
	}
};


// Specify the Module and ModuleWidget subclass, human-readable
// author name for categorization per plugin, module slug (should never
// change), human-readable module name, and any number of tags
// (found in `include/tags.hpp`) separated by commas.
Model *modelMorphingVCO = Model::create<MorphingVCO, MorphingVCOWidget>("SigmaDelta", "MorphingVCO", "Morphing Voltage Controlled Oscillator", OSCILLATOR_TAG);
