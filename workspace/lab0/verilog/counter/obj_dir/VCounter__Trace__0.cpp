// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VCounter__Syms.h"


void VCounter___024root__trace_chg_0_sub_0(VCounter___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void VCounter___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root__trace_chg_0\n"); );
    // Init
    VCounter___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VCounter___024root*>(voidSelf);
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    VCounter___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void VCounter___024root__trace_chg_0_sub_0(VCounter___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelf->clk));
    bufp->chgBit(oldp+1,(vlSelf->rst));
    bufp->chgSData(oldp+2,(vlSelf->max),9);
    bufp->chgSData(oldp+3,(vlSelf->out),9);
    bufp->chgSData(oldp+4,(vlSelf->Counter__DOT__cnt),9);
}

void VCounter___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VCounter___024root__trace_cleanup\n"); );
    // Init
    VCounter___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VCounter___024root*>(voidSelf);
    VCounter__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
