// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "VCounter__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

VCounter::VCounter(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new VCounter__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , rst{vlSymsp->TOP.rst}
    , max{vlSymsp->TOP.max}
    , out{vlSymsp->TOP.out}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

VCounter::VCounter(const char* _vcname__)
    : VCounter(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

VCounter::~VCounter() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void VCounter___024root___eval_debug_assertions(VCounter___024root* vlSelf);
#endif  // VL_DEBUG
void VCounter___024root___eval_static(VCounter___024root* vlSelf);
void VCounter___024root___eval_initial(VCounter___024root* vlSelf);
void VCounter___024root___eval_settle(VCounter___024root* vlSelf);
void VCounter___024root___eval(VCounter___024root* vlSelf);

void VCounter::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate VCounter::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    VCounter___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        VCounter___024root___eval_static(&(vlSymsp->TOP));
        VCounter___024root___eval_initial(&(vlSymsp->TOP));
        VCounter___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    VCounter___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool VCounter::eventsPending() { return false; }

uint64_t VCounter::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* VCounter::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void VCounter___024root___eval_final(VCounter___024root* vlSelf);

VL_ATTR_COLD void VCounter::final() {
    VCounter___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* VCounter::hierName() const { return vlSymsp->name(); }
const char* VCounter::modelName() const { return "VCounter"; }
unsigned VCounter::threads() const { return 1; }
void VCounter::prepareClone() const { contextp()->prepareClone(); }
void VCounter::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> VCounter::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void VCounter___024root__trace_decl_types(VerilatedVcd* tracep);

void VCounter___024root__trace_init_top(VCounter___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VCounter___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VCounter___024root*>(voidSelf);
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    VCounter___024root__trace_decl_types(tracep);
    VCounter___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void VCounter___024root__trace_register(VCounter___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void VCounter::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'VCounter::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    VCounter___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
