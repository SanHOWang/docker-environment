// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VCounter.h for the primary calling header

#include "VCounter__pch.h"
#include "VCounter___024root.h"

VL_ATTR_COLD void VCounter___024root___eval_static(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_static\n"); );
}

VL_ATTR_COLD void VCounter___024root___eval_initial(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_initial\n"); );
    // Body
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = vlSelf->rst;
}

VL_ATTR_COLD void VCounter___024root___eval_final(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VCounter___024root___dump_triggers__stl(VCounter___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool VCounter___024root___eval_phase__stl(VCounter___024root* vlSelf);

VL_ATTR_COLD void VCounter___024root___eval_settle(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_settle\n"); );
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelf->__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            VCounter___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("Counter.v", 1, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (VCounter___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VCounter___024root___dump_triggers__stl(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ vlSelf->__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VCounter___024root___stl_sequent__TOP__0(VCounter___024root* vlSelf);

VL_ATTR_COLD void VCounter___024root___eval_stl(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VCounter___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD void VCounter___024root___stl_sequent__TOP__0(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___stl_sequent__TOP__0\n"); );
    // Body
    vlSelf->out = vlSelf->Counter__DOT__cnt;
}

VL_ATTR_COLD void VCounter___024root___eval_triggers__stl(VCounter___024root* vlSelf);

VL_ATTR_COLD bool VCounter___024root___eval_phase__stl(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    VCounter___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        VCounter___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VCounter___024root___dump_triggers__act(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ vlSelf->__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VCounter___024root___dump_triggers__nba(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ vlSelf->__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VCounter___024root___ctor_var_reset(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->rst = VL_RAND_RESET_I(1);
    vlSelf->max = VL_RAND_RESET_I(9);
    vlSelf->out = VL_RAND_RESET_I(9);
    vlSelf->Counter__DOT__cnt = VL_RAND_RESET_I(9);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = VL_RAND_RESET_I(1);
}
