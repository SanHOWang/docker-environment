// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VCounter.h for the primary calling header

#include "VCounter__pch.h"
#include "VCounter__Syms.h"
#include "VCounter___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void VCounter___024root___dump_triggers__act(VCounter___024root* vlSelf);
#endif  // VL_DEBUG

void VCounter___024root___eval_triggers__act(VCounter___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, (((IData)(vlSelf->clk) 
                                      & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))) 
                                     | ((IData)(vlSelf->rst) 
                                        & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__rst__0)))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = vlSelf->rst;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        VCounter___024root___dump_triggers__act(vlSelf);
    }
#endif
}
