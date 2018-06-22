
/* This file was generated automatically by the Snowball to ANSI C compiler */

#include "../runtime/header.h"

#ifdef __cplusplus
extern "C" {
#endif
extern int kraaij_pohlmann_UTF_8_stem(struct SN_env * z);
#ifdef __cplusplus
}
#endif
static int r_measure(struct SN_env * z);
static int r_Lose_infix(struct SN_env * z);
static int r_Lose_prefix(struct SN_env * z);
static int r_Step_1c(struct SN_env * z);
static int r_Step_6(struct SN_env * z);
static int r_Step_7(struct SN_env * z);
static int r_Step_4(struct SN_env * z);
static int r_Step_3(struct SN_env * z);
static int r_Step_2(struct SN_env * z);
static int r_Step_1(struct SN_env * z);
static int r_lengthen_V(struct SN_env * z);
static int r_VX(struct SN_env * z);
static int r_V(struct SN_env * z);
static int r_C(struct SN_env * z);
static int r_R2(struct SN_env * z);
static int r_R1(struct SN_env * z);
#ifdef __cplusplus
extern "C" {
#endif


extern struct SN_env * kraaij_pohlmann_UTF_8_create_env(void);
extern void kraaij_pohlmann_UTF_8_close_env(struct SN_env * z);


#ifdef __cplusplus
}
#endif
static const symbol s_0_0[3] = { 'n', 'd', 'e' };
static const symbol s_0_1[2] = { 'e', 'n' };
static const symbol s_0_2[1] = { 's' };
static const symbol s_0_3[2] = { '\'', 's' };
static const symbol s_0_4[2] = { 'e', 's' };
static const symbol s_0_5[3] = { 'i', 'e', 's' };
static const symbol s_0_6[3] = { 'a', 'u', 's' };

static const struct among a_0[7] =
{
/*  0 */ { 3, s_0_0, -1, 7, 0},
/*  1 */ { 2, s_0_1, -1, 6, 0},
/*  2 */ { 1, s_0_2, -1, 2, 0},
/*  3 */ { 2, s_0_3, 2, 1, 0},
/*  4 */ { 2, s_0_4, 2, 4, 0},
/*  5 */ { 3, s_0_5, 4, 3, 0},
/*  6 */ { 3, s_0_6, 2, 5, 0}
};

static const symbol s_1_0[2] = { 'd', 'e' };
static const symbol s_1_1[2] = { 'g', 'e' };
static const symbol s_1_2[5] = { 'i', 's', 'c', 'h', 'e' };
static const symbol s_1_3[2] = { 'j', 'e' };
static const symbol s_1_4[5] = { 'l', 'i', 'j', 'k', 'e' };
static const symbol s_1_5[2] = { 'l', 'e' };
static const symbol s_1_6[3] = { 'e', 'n', 'e' };
static const symbol s_1_7[2] = { 'r', 'e' };
static const symbol s_1_8[2] = { 's', 'e' };
static const symbol s_1_9[2] = { 't', 'e' };
static const symbol s_1_10[4] = { 'i', 'e', 'v', 'e' };

static const struct among a_1[11] =
{
/*  0 */ { 2, s_1_0, -1, 5, 0},
/*  1 */ { 2, s_1_1, -1, 2, 0},
/*  2 */ { 5, s_1_2, -1, 4, 0},
/*  3 */ { 2, s_1_3, -1, 1, 0},
/*  4 */ { 5, s_1_4, -1, 3, 0},
/*  5 */ { 2, s_1_5, -1, 9, 0},
/*  6 */ { 3, s_1_6, -1, 10, 0},
/*  7 */ { 2, s_1_7, -1, 8, 0},
/*  8 */ { 2, s_1_8, -1, 7, 0},
/*  9 */ { 2, s_1_9, -1, 6, 0},
/* 10 */ { 4, s_1_10, -1, 11, 0}
};

static const symbol s_2_0[4] = { 'h', 'e', 'i', 'd' };
static const symbol s_2_1[3] = { 'f', 'i', 'e' };
static const symbol s_2_2[3] = { 'g', 'i', 'e' };
static const symbol s_2_3[4] = { 'a', 't', 'i', 'e' };
static const symbol s_2_4[4] = { 'i', 's', 'm', 'e' };
static const symbol s_2_5[3] = { 'i', 'n', 'g' };
static const symbol s_2_6[4] = { 'a', 'r', 'i', 'j' };
static const symbol s_2_7[4] = { 'e', 'r', 'i', 'j' };
static const symbol s_2_8[3] = { 's', 'e', 'l' };
static const symbol s_2_9[4] = { 'r', 'd', 'e', 'r' };
static const symbol s_2_10[4] = { 's', 't', 'e', 'r' };
static const symbol s_2_11[5] = { 'i', 't', 'e', 'i', 't' };
static const symbol s_2_12[3] = { 'd', 's', 't' };
static const symbol s_2_13[3] = { 't', 's', 't' };

static const struct among a_2[14] =
{
/*  0 */ { 4, s_2_0, -1, 3, 0},
/*  1 */ { 3, s_2_1, -1, 7, 0},
/*  2 */ { 3, s_2_2, -1, 8, 0},
/*  3 */ { 4, s_2_3, -1, 1, 0},
/*  4 */ { 4, s_2_4, -1, 5, 0},
/*  5 */ { 3, s_2_5, -1, 5, 0},
/*  6 */ { 4, s_2_6, -1, 6, 0},
/*  7 */ { 4, s_2_7, -1, 5, 0},
/*  8 */ { 3, s_2_8, -1, 3, 0},
/*  9 */ { 4, s_2_9, -1, 4, 0},
/* 10 */ { 4, s_2_10, -1, 3, 0},
/* 11 */ { 5, s_2_11, -1, 2, 0},
/* 12 */ { 3, s_2_12, -1, 10, 0},
/* 13 */ { 3, s_2_13, -1, 9, 0}
};

static const symbol s_3_0[3] = { 'e', 'n', 'd' };
static const symbol s_3_1[5] = { 'a', 't', 'i', 'e', 'f' };
static const symbol s_3_2[4] = { 'e', 'r', 'i', 'g' };
static const symbol s_3_3[6] = { 'a', 'c', 'h', 't', 'i', 'g' };
static const symbol s_3_4[6] = { 'i', 'o', 'n', 'e', 'e', 'l' };
static const symbol s_3_5[4] = { 'b', 'a', 'a', 'r' };
static const symbol s_3_6[4] = { 'l', 'a', 'a', 'r' };
static const symbol s_3_7[4] = { 'n', 'a', 'a', 'r' };
static const symbol s_3_8[4] = { 'r', 'a', 'a', 'r' };
static const symbol s_3_9[6] = { 'e', 'r', 'i', 'g', 'e', 'r' };
static const symbol s_3_10[8] = { 'a', 'c', 'h', 't', 'i', 'g', 'e', 'r' };
static const symbol s_3_11[6] = { 'l', 'i', 'j', 'k', 'e', 'r' };
static const symbol s_3_12[4] = { 't', 'a', 'n', 't' };
static const symbol s_3_13[6] = { 'e', 'r', 'i', 'g', 's', 't' };
static const symbol s_3_14[8] = { 'a', 'c', 'h', 't', 'i', 'g', 's', 't' };
static const symbol s_3_15[6] = { 'l', 'i', 'j', 'k', 's', 't' };

static const struct among a_3[16] =
{
/*  0 */ { 3, s_3_0, -1, 10, 0},
/*  1 */ { 5, s_3_1, -1, 2, 0},
/*  2 */ { 4, s_3_2, -1, 10, 0},
/*  3 */ { 6, s_3_3, -1, 9, 0},
/*  4 */ { 6, s_3_4, -1, 1, 0},
/*  5 */ { 4, s_3_5, -1, 3, 0},
/*  6 */ { 4, s_3_6, -1, 5, 0},
/*  7 */ { 4, s_3_7, -1, 4, 0},
/*  8 */ { 4, s_3_8, -1, 6, 0},
/*  9 */ { 6, s_3_9, -1, 10, 0},
/* 10 */ { 8, s_3_10, -1, 9, 0},
/* 11 */ { 6, s_3_11, -1, 8, 0},
/* 12 */ { 4, s_3_12, -1, 7, 0},
/* 13 */ { 6, s_3_13, -1, 10, 0},
/* 14 */ { 8, s_3_14, -1, 9, 0},
/* 15 */ { 6, s_3_15, -1, 8, 0}
};

static const symbol s_4_0[2] = { 'i', 'g' };
static const symbol s_4_1[4] = { 'i', 'g', 'e', 'r' };
static const symbol s_4_2[4] = { 'i', 'g', 's', 't' };

static const struct among a_4[3] =
{
/*  0 */ { 2, s_4_0, -1, 1, 0},
/*  1 */ { 4, s_4_1, -1, 1, 0},
/*  2 */ { 4, s_4_2, -1, 1, 0}
};

static const symbol s_5_0[2] = { 'f', 't' };
static const symbol s_5_1[2] = { 'k', 't' };
static const symbol s_5_2[2] = { 'p', 't' };

static const struct among a_5[3] =
{
/*  0 */ { 2, s_5_0, -1, 2, 0},
/*  1 */ { 2, s_5_1, -1, 1, 0},
/*  2 */ { 2, s_5_2, -1, 3, 0}
};

static const symbol s_6_0[2] = { 'b', 'b' };
static const symbol s_6_1[2] = { 'c', 'c' };
static const symbol s_6_2[2] = { 'd', 'd' };
static const symbol s_6_3[2] = { 'f', 'f' };
static const symbol s_6_4[2] = { 'g', 'g' };
static const symbol s_6_5[2] = { 'h', 'h' };
static const symbol s_6_6[2] = { 'j', 'j' };
static const symbol s_6_7[2] = { 'k', 'k' };
static const symbol s_6_8[2] = { 'l', 'l' };
static const symbol s_6_9[2] = { 'm', 'm' };
static const symbol s_6_10[2] = { 'n', 'n' };
static const symbol s_6_11[2] = { 'p', 'p' };
static const symbol s_6_12[2] = { 'q', 'q' };
static const symbol s_6_13[2] = { 'r', 'r' };
static const symbol s_6_14[2] = { 's', 's' };
static const symbol s_6_15[2] = { 't', 't' };
static const symbol s_6_16[1] = { 'v' };
static const symbol s_6_17[2] = { 'v', 'v' };
static const symbol s_6_18[2] = { 'w', 'w' };
static const symbol s_6_19[2] = { 'x', 'x' };
static const symbol s_6_20[1] = { 'z' };
static const symbol s_6_21[2] = { 'z', 'z' };

static const struct among a_6[22] =
{
/*  0 */ { 2, s_6_0, -1, 1, 0},
/*  1 */ { 2, s_6_1, -1, 2, 0},
/*  2 */ { 2, s_6_2, -1, 3, 0},
/*  3 */ { 2, s_6_3, -1, 4, 0},
/*  4 */ { 2, s_6_4, -1, 5, 0},
/*  5 */ { 2, s_6_5, -1, 6, 0},
/*  6 */ { 2, s_6_6, -1, 7, 0},
/*  7 */ { 2, s_6_7, -1, 8, 0},
/*  8 */ { 2, s_6_8, -1, 9, 0},
/*  9 */ { 2, s_6_9, -1, 10, 0},
/* 10 */ { 2, s_6_10, -1, 11, 0},
/* 11 */ { 2, s_6_11, -1, 12, 0},
/* 12 */ { 2, s_6_12, -1, 13, 0},
/* 13 */ { 2, s_6_13, -1, 14, 0},
/* 14 */ { 2, s_6_14, -1, 15, 0},
/* 15 */ { 2, s_6_15, -1, 16, 0},
/* 16 */ { 1, s_6_16, -1, 21, 0},
/* 17 */ { 2, s_6_17, 16, 17, 0},
/* 18 */ { 2, s_6_18, -1, 18, 0},
/* 19 */ { 2, s_6_19, -1, 19, 0},
/* 20 */ { 1, s_6_20, -1, 22, 0},
/* 21 */ { 2, s_6_21, 20, 20, 0}
};

static const symbol s_7_0[1] = { 'd' };
static const symbol s_7_1[1] = { 't' };

static const struct among a_7[2] =
{
/*  0 */ { 1, s_7_0, -1, 1, 0},
/*  1 */ { 1, s_7_1, -1, 2, 0}
};

static const unsigned char g_v[] = { 17, 65, 16, 1 };

static const unsigned char g_v_WX[] = { 17, 65, 208, 1 };

static const unsigned char g_AOU[] = { 1, 64, 16 };

static const unsigned char g_AIOU[] = { 1, 65, 16 };

static const symbol s_0[] = { 'i', 'j' };
static const symbol s_1[] = { 'i', 'j' };
static const symbol s_2[] = { 'i', 'j' };
static const symbol s_3[] = { 'e' };
static const symbol s_4[] = { 't' };
static const symbol s_5[] = { 'i', 'e' };
static const symbol s_6[] = { 'a', 'r' };
static const symbol s_7[] = { 'e', 'r' };
static const symbol s_8[] = { 'e' };
static const symbol s_9[] = { 'a', 'u' };
static const symbol s_10[] = { 'h', 'e', 'd' };
static const symbol s_11[] = { 'h', 'e', 'i', 'd' };
static const symbol s_12[] = { 'n', 'd' };
static const symbol s_13[] = { 'd' };
static const symbol s_14[] = { 'i' };
static const symbol s_15[] = { 'j' };
static const symbol s_16[] = { 'n', 'd' };
static const symbol s_17[] = { '\'', 't' };
static const symbol s_18[] = { 'e', 't' };
static const symbol s_19[] = { 'r', 'n', 't' };
static const symbol s_20[] = { 'r', 'n' };
static const symbol s_21[] = { 't' };
static const symbol s_22[] = { 'i', 'n', 'k' };
static const symbol s_23[] = { 'i', 'n', 'g' };
static const symbol s_24[] = { 'm', 'p' };
static const symbol s_25[] = { 'm' };
static const symbol s_26[] = { '\'' };
static const symbol s_27[] = { 'g' };
static const symbol s_28[] = { 'l', 'i', 'j', 'k' };
static const symbol s_29[] = { 'i', 's', 'c', 'h' };
static const symbol s_30[] = { 't' };
static const symbol s_31[] = { 's' };
static const symbol s_32[] = { 'r' };
static const symbol s_33[] = { 'l' };
static const symbol s_34[] = { 'e', 'n' };
static const symbol s_35[] = { 'i', 'e', 'f' };
static const symbol s_36[] = { 'e', 'e', 'r' };
static const symbol s_37[] = { 'r' };
static const symbol s_38[] = { 'a', 'a', 'r' };
static const symbol s_39[] = { 'f' };
static const symbol s_40[] = { 'g' };
static const symbol s_41[] = { 't' };
static const symbol s_42[] = { 'd' };
static const symbol s_43[] = { 'i', 'e' };
static const symbol s_44[] = { 'e', 'e', 'r' };
static const symbol s_45[] = { 'n' };
static const symbol s_46[] = { 'l' };
static const symbol s_47[] = { 'r' };
static const symbol s_48[] = { 't', 'e', 'e', 'r' };
static const symbol s_49[] = { 'l', 'i', 'j', 'k' };
static const symbol s_50[] = { 'k' };
static const symbol s_51[] = { 'f' };
static const symbol s_52[] = { 'p' };
static const symbol s_53[] = { 'b' };
static const symbol s_54[] = { 'c' };
static const symbol s_55[] = { 'd' };
static const symbol s_56[] = { 'f' };
static const symbol s_57[] = { 'g' };
static const symbol s_58[] = { 'h' };
static const symbol s_59[] = { 'j' };
static const symbol s_60[] = { 'k' };
static const symbol s_61[] = { 'l' };
static const symbol s_62[] = { 'm' };
static const symbol s_63[] = { 'n' };
static const symbol s_64[] = { 'p' };
static const symbol s_65[] = { 'q' };
static const symbol s_66[] = { 'r' };
static const symbol s_67[] = { 's' };
static const symbol s_68[] = { 't' };
static const symbol s_69[] = { 'v' };
static const symbol s_70[] = { 'w' };
static const symbol s_71[] = { 'x' };
static const symbol s_72[] = { 'z' };
static const symbol s_73[] = { 'f' };
static const symbol s_74[] = { 's' };
static const symbol s_75[] = { 'n' };
static const symbol s_76[] = { 'h' };
static const symbol s_77[] = { 'g', 'e' };
static const symbol s_78[] = { 'g', 'e' };
static const symbol s_79[] = { 'i', 'j' };
static const symbol s_80[] = { 'i', 'j' };
static const symbol s_81[] = { 'y' };
static const symbol s_82[] = { 'Y' };
static const symbol s_83[] = { 'y' };
static const symbol s_84[] = { 'Y' };
static const symbol s_85[] = { 'Y' };
static const symbol s_86[] = { 'y' };

static int r_R1(struct SN_env * z) {
    z->I[0] = z->c; /* setmark x, line 32 */
    if (!(z->I[0] >= z->I[1])) return 0;
    return 1;
}

static int r_R2(struct SN_env * z) {
    z->I[0] = z->c; /* setmark x, line 33 */
    if (!(z->I[0] >= z->I[2])) return 0;
    return 1;
}

static int r_V(struct SN_env * z) {
    {   int m_test = z->l - z->c; /* test, line 35 */
        {   int m1 = z->l - z->c; (void)m1; /* or, line 35 */
            if (in_grouping_b_U(z, g_v, 97, 121, 0)) goto lab1;
            goto lab0;
        lab1:
            z->c = z->l - m1;
            if (!(eq_s_b(z, 2, s_0))) return 0;
        }
    lab0:
        z->c = z->l - m_test;
    }
    return 1;
}

static int r_VX(struct SN_env * z) {
    {   int m_test = z->l - z->c; /* test, line 36 */
        {   int ret = skip_utf8(z->p, z->c, z->lb, 0, -1);
            if (ret < 0) return 0;
            z->c = ret; /* next, line 36 */
        }
        {   int m1 = z->l - z->c; (void)m1; /* or, line 36 */
            if (in_grouping_b_U(z, g_v, 97, 121, 0)) goto lab1;
            goto lab0;
        lab1:
            z->c = z->l - m1;
            if (!(eq_s_b(z, 2, s_1))) return 0;
        }
    lab0:
        z->c = z->l - m_test;
    }
    return 1;
}

static int r_C(struct SN_env * z) {
    {   int m_test = z->l - z->c; /* test, line 37 */
        {   int m1 = z->l - z->c; (void)m1; /* not, line 37 */
            if (!(eq_s_b(z, 2, s_2))) goto lab0;
            return 0;
        lab0:
            z->c = z->l - m1;
        }
        if (out_grouping_b_U(z, g_v, 97, 121, 0)) return 0;
        z->c = z->l - m_test;
    }
    return 1;
}

static int r_lengthen_V(struct SN_env * z) {
    {   int m1 = z->l - z->c; (void)m1; /* do, line 39 */
        if (out_grouping_b_U(z, g_v_WX, 97, 121, 0)) goto lab0;
        z->ket = z->c; /* [, line 40 */
        {   int m2 = z->l - z->c; (void)m2; /* or, line 40 */
            if (in_grouping_b_U(z, g_AOU, 97, 117, 0)) goto lab2;
            z->bra = z->c; /* ], line 40 */
            {   int m_test = z->l - z->c; /* test, line 40 */
                {   int m3 = z->l - z->c; (void)m3; /* or, line 40 */
                    if (out_grouping_b_U(z, g_v, 97, 121, 0)) goto lab4;
                    goto lab3;
                lab4:
                    z->c = z->l - m3;
                    if (z->c > z->lb) goto lab2; /* atlimit, line 40 */
                }
            lab3:
                z->c = z->l - m_test;
            }
            goto lab1;
        lab2:
            z->c = z->l - m2;
            if (!(eq_s_b(z, 1, s_3))) goto lab0;
            z->bra = z->c; /* ], line 41 */
            {   int m_test = z->l - z->c; /* test, line 41 */
                {   int m4 = z->l - z->c; (void)m4; /* or, line 41 */
                    if (out_grouping_b_U(z, g_v, 97, 121, 0)) goto lab6;
                    goto lab5;
                lab6:
                    z->c = z->l - m4;
                    if (z->c > z->lb) goto lab0; /* atlimit, line 41 */
                }
            lab5:
                {   int m5 = z->l - z->c; (void)m5; /* not, line 42 */
                    if (in_grouping_b_U(z, g_AIOU, 97, 117, 0)) goto lab7;
                    goto lab0;
                lab7:
                    z->c = z->l - m5;
                }
                {   int m6 = z->l - z->c; (void)m6; /* not, line 43 */
                    {   int ret = skip_utf8(z->p, z->c, z->lb, 0, -1);
                        if (ret < 0) goto lab8;
                        z->c = ret; /* next, line 43 */
                    }
                    if (in_grouping_b_U(z, g_AIOU, 97, 117, 0)) goto lab8;
                    if (out_grouping_b_U(z, g_v, 97, 121, 0)) goto lab8;
                    goto lab0;
                lab8:
                    z->c = z->l - m6;
                }
                z->c = z->l - m_test;
            }
        }
    lab1:
        z->S[0] = slice_to(z, z->S[0]); /* -> ch, line 44 */
        if (z->S[0] == 0) return -1; /* -> ch, line 44 */
        {   int c_keep = z->c;
            int ret = insert_v(z, z->c, z->c, z->S[0]); /* <+ ch, line 44 */
            z->c = c_keep;
            if (ret < 0) return ret;
        }
    lab0:
        z->c = z->l - m1;
    }
    return 1;
}

static int r_Step_1(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 49 */
    if (z->c <= z->lb || z->p[z->c - 1] >> 5 != 3 || !((540704 >> (z->p[z->c - 1] & 0x1f)) & 1)) return 0;
    among_var = find_among_b(z, a_0, 7); /* among, line 49 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 49 */
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int ret = slice_del(z); /* delete, line 51 */
                if (ret < 0) return ret;
            }
            break;
        case 2:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 52 */
                if (ret < 0) return ret;
            }
            {   int m1 = z->l - z->c; (void)m1; /* not, line 52 */
                if (!(eq_s_b(z, 1, s_4))) goto lab0;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab0; /* call R1, line 52 */
                    if (ret < 0) return ret;
                }
                return 0;
            lab0:
                z->c = z->l - m1;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 52 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 52 */
                if (ret < 0) return ret;
            }
            break;
        case 3:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 53 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 2, s_5); /* <-, line 53 */
                if (ret < 0) return ret;
            }
            break;
        case 4:
            {   int m2 = z->l - z->c; (void)m2; /* or, line 55 */
                if (!(eq_s_b(z, 2, s_6))) goto lab2;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab2; /* call R1, line 55 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) goto lab2; /* call C, line 55 */
                    if (ret < 0) return ret;
                }
                z->bra = z->c; /* ], line 55 */
                {   int ret = slice_del(z); /* delete, line 55 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_lengthen_V(z);
                    if (ret == 0) goto lab2; /* call lengthen_V, line 55 */
                    if (ret < 0) return ret;
                }
                goto lab1;
            lab2:
                z->c = z->l - m2;
                if (!(eq_s_b(z, 2, s_7))) goto lab3;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab3; /* call R1, line 56 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) goto lab3; /* call C, line 56 */
                    if (ret < 0) return ret;
                }
                z->bra = z->c; /* ], line 56 */
                {   int ret = slice_del(z); /* delete, line 56 */
                    if (ret < 0) return ret;
                }
                goto lab1;
            lab3:
                z->c = z->l - m2;
                {   int ret = r_R1(z);
                    if (ret == 0) return 0; /* call R1, line 57 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) return 0; /* call C, line 57 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 1, s_8); /* <-, line 57 */
                    if (ret < 0) return ret;
                }
            }
        lab1:
            break;
        case 5:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 59 */
                if (ret < 0) return ret;
            }
            {   int ret = r_V(z);
                if (ret == 0) return 0; /* call V, line 59 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 2, s_9); /* <-, line 59 */
                if (ret < 0) return ret;
            }
            break;
        case 6:
            {   int m3 = z->l - z->c; (void)m3; /* or, line 60 */
                if (!(eq_s_b(z, 3, s_10))) goto lab5;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab5; /* call R1, line 60 */
                    if (ret < 0) return ret;
                }
                z->bra = z->c; /* ], line 60 */
                {   int ret = slice_from_s(z, 4, s_11); /* <-, line 60 */
                    if (ret < 0) return ret;
                }
                goto lab4;
            lab5:
                z->c = z->l - m3;
                if (!(eq_s_b(z, 2, s_12))) goto lab6;
                {   int ret = slice_del(z); /* delete, line 61 */
                    if (ret < 0) return ret;
                }
                goto lab4;
            lab6:
                z->c = z->l - m3;
                if (!(eq_s_b(z, 1, s_13))) goto lab7;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab7; /* call R1, line 62 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) goto lab7; /* call C, line 62 */
                    if (ret < 0) return ret;
                }
                z->bra = z->c; /* ], line 62 */
                {   int ret = slice_del(z); /* delete, line 62 */
                    if (ret < 0) return ret;
                }
                goto lab4;
            lab7:
                z->c = z->l - m3;
                {   int m4 = z->l - z->c; (void)m4; /* or, line 63 */
                    if (!(eq_s_b(z, 1, s_14))) goto lab10;
                    goto lab9;
                lab10:
                    z->c = z->l - m4;
                    if (!(eq_s_b(z, 1, s_15))) goto lab8;
                }
            lab9:
                {   int ret = r_V(z);
                    if (ret == 0) goto lab8; /* call V, line 63 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 63 */
                    if (ret < 0) return ret;
                }
                goto lab4;
            lab8:
                z->c = z->l - m3;
                {   int ret = r_R1(z);
                    if (ret == 0) return 0; /* call R1, line 64 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) return 0; /* call C, line 64 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 64 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_lengthen_V(z);
                    if (ret == 0) return 0; /* call lengthen_V, line 64 */
                    if (ret < 0) return ret;
                }
            }
        lab4:
            break;
        case 7:
            {   int ret = slice_from_s(z, 2, s_16); /* <-, line 65 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Step_2(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 71 */
    if (z->c - 1 <= z->lb || z->p[z->c - 1] != 101) return 0;
    among_var = find_among_b(z, a_1, 11); /* among, line 71 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 71 */
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int m1 = z->l - z->c; (void)m1; /* or, line 72 */
                if (!(eq_s_b(z, 2, s_17))) goto lab1;
                z->bra = z->c; /* ], line 72 */
                {   int ret = slice_del(z); /* delete, line 72 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab1:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 2, s_18))) goto lab2;
                z->bra = z->c; /* ], line 73 */
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab2; /* call R1, line 73 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) goto lab2; /* call C, line 73 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 73 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab2:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 3, s_19))) goto lab3;
                z->bra = z->c; /* ], line 74 */
                {   int ret = slice_from_s(z, 2, s_20); /* <-, line 74 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab3:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 1, s_21))) goto lab4;
                z->bra = z->c; /* ], line 75 */
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab4; /* call R1, line 75 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_VX(z);
                    if (ret == 0) goto lab4; /* call VX, line 75 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 75 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab4:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 3, s_22))) goto lab5;
                z->bra = z->c; /* ], line 76 */
                {   int ret = slice_from_s(z, 3, s_23); /* <-, line 76 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab5:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 2, s_24))) goto lab6;
                z->bra = z->c; /* ], line 77 */
                {   int ret = slice_from_s(z, 1, s_25); /* <-, line 77 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab6:
                z->c = z->l - m1;
                if (!(eq_s_b(z, 1, s_26))) goto lab7;
                z->bra = z->c; /* ], line 78 */
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab7; /* call R1, line 78 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 78 */
                    if (ret < 0) return ret;
                }
                goto lab0;
            lab7:
                z->c = z->l - m1;
                z->bra = z->c; /* ], line 79 */
                {   int ret = r_R1(z);
                    if (ret == 0) return 0; /* call R1, line 79 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) return 0; /* call C, line 79 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 79 */
                    if (ret < 0) return ret;
                }
            }
        lab0:
            break;
        case 2:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 80 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_27); /* <-, line 80 */
                if (ret < 0) return ret;
            }
            break;
        case 3:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 81 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 4, s_28); /* <-, line 81 */
                if (ret < 0) return ret;
            }
            break;
        case 4:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 82 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 4, s_29); /* <-, line 82 */
                if (ret < 0) return ret;
            }
            break;
        case 5:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 83 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 83 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 83 */
                if (ret < 0) return ret;
            }
            break;
        case 6:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 84 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_30); /* <-, line 84 */
                if (ret < 0) return ret;
            }
            break;
        case 7:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 85 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_31); /* <-, line 85 */
                if (ret < 0) return ret;
            }
            break;
        case 8:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 86 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_32); /* <-, line 86 */
                if (ret < 0) return ret;
            }
            break;
        case 9:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 87 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 87 */
                if (ret < 0) return ret;
            }
            {   int ret = insert_s(z, z->c, z->c, 1, s_33); /* attach, line 87 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 87 */
                if (ret < 0) return ret;
            }
            break;
        case 10:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 88 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 88 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 88 */
                if (ret < 0) return ret;
            }
            {   int ret = insert_s(z, z->c, z->c, 2, s_34); /* attach, line 88 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 88 */
                if (ret < 0) return ret;
            }
            break;
        case 11:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 89 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 89 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 3, s_35); /* <-, line 89 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Step_3(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 95 */
    if (z->c - 2 <= z->lb || z->p[z->c - 1] >> 5 != 3 || !((1316016 >> (z->p[z->c - 1] & 0x1f)) & 1)) return 0;
    among_var = find_among_b(z, a_2, 14); /* among, line 95 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 95 */
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 96 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 3, s_36); /* <-, line 96 */
                if (ret < 0) return ret;
            }
            break;
        case 2:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 97 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 97 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 97 */
                if (ret < 0) return ret;
            }
            break;
        case 3:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 100 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 100 */
                if (ret < 0) return ret;
            }
            break;
        case 4:
            {   int ret = slice_from_s(z, 1, s_37); /* <-, line 101 */
                if (ret < 0) return ret;
            }
            break;
        case 5:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 104 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 104 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 104 */
                if (ret < 0) return ret;
            }
            break;
        case 6:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 105 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 105 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 3, s_38); /* <-, line 105 */
                if (ret < 0) return ret;
            }
            break;
        case 7:
            {   int ret = r_R2(z);
                if (ret == 0) return 0; /* call R2, line 106 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 106 */
                if (ret < 0) return ret;
            }
            {   int ret = insert_s(z, z->c, z->c, 1, s_39); /* attach, line 106 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 106 */
                if (ret < 0) return ret;
            }
            break;
        case 8:
            {   int ret = r_R2(z);
                if (ret == 0) return 0; /* call R2, line 107 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_del(z); /* delete, line 107 */
                if (ret < 0) return ret;
            }
            {   int ret = insert_s(z, z->c, z->c, 1, s_40); /* attach, line 107 */
                if (ret < 0) return ret;
            }
            {   int ret = r_lengthen_V(z);
                if (ret == 0) return 0; /* call lengthen_V, line 107 */
                if (ret < 0) return ret;
            }
            break;
        case 9:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 108 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 108 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_41); /* <-, line 108 */
                if (ret < 0) return ret;
            }
            break;
        case 10:
            {   int ret = r_R1(z);
                if (ret == 0) return 0; /* call R1, line 109 */
                if (ret < 0) return ret;
            }
            {   int ret = r_C(z);
                if (ret == 0) return 0; /* call C, line 109 */
                if (ret < 0) return ret;
            }
            {   int ret = slice_from_s(z, 1, s_42); /* <-, line 109 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Step_4(struct SN_env * z) {
    int among_var;
    {   int m1 = z->l - z->c; (void)m1; /* or, line 134 */
        z->ket = z->c; /* [, line 115 */
        if (z->c - 2 <= z->lb || z->p[z->c - 1] >> 5 != 3 || !((1315024 >> (z->p[z->c - 1] & 0x1f)) & 1)) goto lab1;
        among_var = find_among_b(z, a_3, 16); /* among, line 115 */
        if (!(among_var)) goto lab1;
        z->bra = z->c; /* ], line 115 */
        switch(among_var) {
            case 0: goto lab1;
            case 1:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 116 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 2, s_43); /* <-, line 116 */
                    if (ret < 0) return ret;
                }
                break;
            case 2:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 117 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 3, s_44); /* <-, line 117 */
                    if (ret < 0) return ret;
                }
                break;
            case 3:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 118 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 118 */
                    if (ret < 0) return ret;
                }
                break;
            case 4:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 119 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_V(z);
                    if (ret == 0) goto lab1; /* call V, line 119 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 1, s_45); /* <-, line 119 */
                    if (ret < 0) return ret;
                }
                break;
            case 5:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 120 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_V(z);
                    if (ret == 0) goto lab1; /* call V, line 120 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 1, s_46); /* <-, line 120 */
                    if (ret < 0) return ret;
                }
                break;
            case 6:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 121 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_V(z);
                    if (ret == 0) goto lab1; /* call V, line 121 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 1, s_47); /* <-, line 121 */
                    if (ret < 0) return ret;
                }
                break;
            case 7:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 122 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 4, s_48); /* <-, line 122 */
                    if (ret < 0) return ret;
                }
                break;
            case 8:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 124 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_from_s(z, 4, s_49); /* <-, line 124 */
                    if (ret < 0) return ret;
                }
                break;
            case 9:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 127 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 127 */
                    if (ret < 0) return ret;
                }
                break;
            case 10:
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 131 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) goto lab1; /* call C, line 131 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 131 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_lengthen_V(z);
                    if (ret == 0) goto lab1; /* call lengthen_V, line 131 */
                    if (ret < 0) return ret;
                }
                break;
        }
        goto lab0;
    lab1:
        z->c = z->l - m1;
        z->ket = z->c; /* [, line 135 */
        if (z->c - 1 <= z->lb || z->p[z->c - 1] >> 5 != 3 || !((1310848 >> (z->p[z->c - 1] & 0x1f)) & 1)) return 0;
        among_var = find_among_b(z, a_4, 3); /* among, line 135 */
        if (!(among_var)) return 0;
        z->bra = z->c; /* ], line 135 */
        switch(among_var) {
            case 0: return 0;
            case 1:
                {   int ret = r_R1(z);
                    if (ret == 0) return 0; /* call R1, line 138 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_C(z);
                    if (ret == 0) return 0; /* call C, line 138 */
                    if (ret < 0) return ret;
                }
                {   int ret = slice_del(z); /* delete, line 138 */
                    if (ret < 0) return ret;
                }
                {   int ret = r_lengthen_V(z);
                    if (ret == 0) return 0; /* call lengthen_V, line 138 */
                    if (ret < 0) return ret;
                }
                break;
        }
    }
lab0:
    return 1;
}

static int r_Step_7(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 145 */
    if (z->c - 1 <= z->lb || z->p[z->c - 1] != 116) return 0;
    among_var = find_among_b(z, a_5, 3); /* among, line 145 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 145 */
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int ret = slice_from_s(z, 1, s_50); /* <-, line 146 */
                if (ret < 0) return ret;
            }
            break;
        case 2:
            {   int ret = slice_from_s(z, 1, s_51); /* <-, line 147 */
                if (ret < 0) return ret;
            }
            break;
        case 3:
            {   int ret = slice_from_s(z, 1, s_52); /* <-, line 148 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Step_6(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 154 */
    if (z->c <= z->lb || z->p[z->c - 1] >> 5 != 3 || !((98532828 >> (z->p[z->c - 1] & 0x1f)) & 1)) return 0;
    among_var = find_among_b(z, a_6, 22); /* among, line 154 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 154 */
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int ret = slice_from_s(z, 1, s_53); /* <-, line 155 */
                if (ret < 0) return ret;
            }
            break;
        case 2:
            {   int ret = slice_from_s(z, 1, s_54); /* <-, line 156 */
                if (ret < 0) return ret;
            }
            break;
        case 3:
            {   int ret = slice_from_s(z, 1, s_55); /* <-, line 157 */
                if (ret < 0) return ret;
            }
            break;
        case 4:
            {   int ret = slice_from_s(z, 1, s_56); /* <-, line 158 */
                if (ret < 0) return ret;
            }
            break;
        case 5:
            {   int ret = slice_from_s(z, 1, s_57); /* <-, line 159 */
                if (ret < 0) return ret;
            }
            break;
        case 6:
            {   int ret = slice_from_s(z, 1, s_58); /* <-, line 160 */
                if (ret < 0) return ret;
            }
            break;
        case 7:
            {   int ret = slice_from_s(z, 1, s_59); /* <-, line 161 */
                if (ret < 0) return ret;
            }
            break;
        case 8:
            {   int ret = slice_from_s(z, 1, s_60); /* <-, line 162 */
                if (ret < 0) return ret;
            }
            break;
        case 9:
            {   int ret = slice_from_s(z, 1, s_61); /* <-, line 163 */
                if (ret < 0) return ret;
            }
            break;
        case 10:
            {   int ret = slice_from_s(z, 1, s_62); /* <-, line 164 */
                if (ret < 0) return ret;
            }
            break;
        case 11:
            {   int ret = slice_from_s(z, 1, s_63); /* <-, line 165 */
                if (ret < 0) return ret;
            }
            break;
        case 12:
            {   int ret = slice_from_s(z, 1, s_64); /* <-, line 166 */
                if (ret < 0) return ret;
            }
            break;
        case 13:
            {   int ret = slice_from_s(z, 1, s_65); /* <-, line 167 */
                if (ret < 0) return ret;
            }
            break;
        case 14:
            {   int ret = slice_from_s(z, 1, s_66); /* <-, line 168 */
                if (ret < 0) return ret;
            }
            break;
        case 15:
            {   int ret = slice_from_s(z, 1, s_67); /* <-, line 169 */
                if (ret < 0) return ret;
            }
            break;
        case 16:
            {   int ret = slice_from_s(z, 1, s_68); /* <-, line 170 */
                if (ret < 0) return ret;
            }
            break;
        case 17:
            {   int ret = slice_from_s(z, 1, s_69); /* <-, line 171 */
                if (ret < 0) return ret;
            }
            break;
        case 18:
            {   int ret = slice_from_s(z, 1, s_70); /* <-, line 172 */
                if (ret < 0) return ret;
            }
            break;
        case 19:
            {   int ret = slice_from_s(z, 1, s_71); /* <-, line 173 */
                if (ret < 0) return ret;
            }
            break;
        case 20:
            {   int ret = slice_from_s(z, 1, s_72); /* <-, line 174 */
                if (ret < 0) return ret;
            }
            break;
        case 21:
            {   int ret = slice_from_s(z, 1, s_73); /* <-, line 175 */
                if (ret < 0) return ret;
            }
            break;
        case 22:
            {   int ret = slice_from_s(z, 1, s_74); /* <-, line 176 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Step_1c(struct SN_env * z) {
    int among_var;
    z->ket = z->c; /* [, line 182 */
    if (z->c <= z->lb || (z->p[z->c - 1] != 100 && z->p[z->c - 1] != 116)) return 0;
    among_var = find_among_b(z, a_7, 2); /* among, line 182 */
    if (!(among_var)) return 0;
    z->bra = z->c; /* ], line 182 */
    {   int ret = r_R1(z);
        if (ret == 0) return 0; /* call R1, line 182 */
        if (ret < 0) return ret;
    }
    {   int ret = r_C(z);
        if (ret == 0) return 0; /* call C, line 182 */
        if (ret < 0) return ret;
    }
    switch(among_var) {
        case 0: return 0;
        case 1:
            {   int m1 = z->l - z->c; (void)m1; /* not, line 183 */
                if (!(eq_s_b(z, 1, s_75))) goto lab0;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab0; /* call R1, line 183 */
                    if (ret < 0) return ret;
                }
                return 0;
            lab0:
                z->c = z->l - m1;
            }
            {   int ret = slice_del(z); /* delete, line 183 */
                if (ret < 0) return ret;
            }
            break;
        case 2:
            {   int m2 = z->l - z->c; (void)m2; /* not, line 184 */
                if (!(eq_s_b(z, 1, s_76))) goto lab1;
                {   int ret = r_R1(z);
                    if (ret == 0) goto lab1; /* call R1, line 184 */
                    if (ret < 0) return ret;
                }
                return 0;
            lab1:
                z->c = z->l - m2;
            }
            {   int ret = slice_del(z); /* delete, line 184 */
                if (ret < 0) return ret;
            }
            break;
    }
    return 1;
}

static int r_Lose_prefix(struct SN_env * z) {
    z->bra = z->c; /* [, line 190 */
    if (!(eq_s(z, 2, s_77))) return 0;
    z->ket = z->c; /* ], line 190 */
    {   int c_test = z->c; /* test, line 190 */
        {   int ret = skip_utf8(z->p, z->c, 0, z->l, + 3);
            if (ret < 0) return 0;
            z->c = ret; /* hop, line 190 */
        }
        z->c = c_test;
    }
    if (out_grouping_U(z, g_v, 97, 121, 1) < 0) return 0; /* goto */ /* grouping v, line 190 */
    if (in_grouping_U(z, g_v, 97, 121, 1) < 0) return 0; /* goto */ /* non v, line 190 */
    z->B[2] = 1; /* set GE_removed, line 191 */
    {   int ret = slice_del(z); /* delete, line 192 */
        if (ret < 0) return ret;
    }
    return 1;
}

static int r_Lose_infix(struct SN_env * z) {
    {   int ret = skip_utf8(z->p, z->c, 0, z->l, 1);
        if (ret < 0) return 0;
        z->c = ret; /* next, line 196 */
    }
    while(1) { /* gopast, line 197 */
        z->bra = z->c; /* [, line 197 */
        if (!(eq_s(z, 2, s_78))) goto lab0;
        z->ket = z->c; /* ], line 197 */
        break;
    lab0:
        {   int ret = skip_utf8(z->p, z->c, 0, z->l, 1);
            if (ret < 0) return 0;
            z->c = ret; /* gopast, line 197 */
        }
    }
    {   int c_test = z->c; /* test, line 197 */
        {   int ret = skip_utf8(z->p, z->c, 0, z->l, + 3);
            if (ret < 0) return 0;
            z->c = ret; /* hop, line 197 */
        }
        z->c = c_test;
    }
    if (out_grouping_U(z, g_v, 97, 121, 1) < 0) return 0; /* goto */ /* grouping v, line 197 */
    if (in_grouping_U(z, g_v, 97, 121, 1) < 0) return 0; /* goto */ /* non v, line 197 */
    z->B[2] = 1; /* set GE_removed, line 198 */
    {   int ret = slice_del(z); /* delete, line 199 */
        if (ret < 0) return ret;
    }
    return 1;
}

static int r_measure(struct SN_env * z) {
    {   int c1 = z->c; /* do, line 203 */
        z->c = z->l; /* tolimit, line 204 */
        z->I[1] = z->c; /* setmark p1, line 205 */
        z->I[2] = z->c; /* setmark p2, line 206 */
        z->c = c1;
    }
    {   int c2 = z->c; /* do, line 208 */
        while(1) { /* repeat, line 209 */
            if (out_grouping_U(z, g_v, 97, 121, 0)) goto lab2;
            continue;
        lab2:
            break;
        }
        {   int i = 1;
            while(1) { /* atleast, line 209 */
                int c3 = z->c;
                {   int c4 = z->c; /* or, line 209 */
                    if (!(eq_s(z, 2, s_79))) goto lab5;
                    goto lab4;
                lab5:
                    z->c = c4;
                    if (in_grouping_U(z, g_v, 97, 121, 0)) goto lab3;
                }
            lab4:
                i--;
                continue;
            lab3:
                z->c = c3;
                break;
            }
            if (i > 0) goto lab1;
        }
        if (out_grouping_U(z, g_v, 97, 121, 0)) goto lab1;
        z->I[1] = z->c; /* setmark p1, line 209 */
        while(1) { /* repeat, line 210 */
            if (out_grouping_U(z, g_v, 97, 121, 0)) goto lab6;
            continue;
        lab6:
            break;
        }
        {   int i = 1;
            while(1) { /* atleast, line 210 */
                int c5 = z->c;
                {   int c6 = z->c; /* or, line 210 */
                    if (!(eq_s(z, 2, s_80))) goto lab9;
                    goto lab8;
                lab9:
                    z->c = c6;
                    if (in_grouping_U(z, g_v, 97, 121, 0)) goto lab7;
                }
            lab8:
                i--;
                continue;
            lab7:
                z->c = c5;
                break;
            }
            if (i > 0) goto lab1;
        }
        if (out_grouping_U(z, g_v, 97, 121, 0)) goto lab1;
        z->I[2] = z->c; /* setmark p2, line 210 */
    lab1:
        z->c = c2;
    }
    return 1;
}

extern int kraaij_pohlmann_UTF_8_stem(struct SN_env * z) {
    z->B[0] = 0; /* unset Y_found, line 216 */
    z->B[1] = 0; /* unset stemmed, line 217 */
    {   int c1 = z->c; /* do, line 218 */
        z->bra = z->c; /* [, line 218 */
        if (!(eq_s(z, 1, s_81))) goto lab0;
        z->ket = z->c; /* ], line 218 */
        {   int ret = slice_from_s(z, 1, s_82); /* <-, line 218 */
            if (ret < 0) return ret;
        }
        z->B[0] = 1; /* set Y_found, line 218 */
    lab0:
        z->c = c1;
    }
    {   int c2 = z->c; /* do, line 219 */
        while(1) { /* repeat, line 219 */
            int c3 = z->c;
            while(1) { /* goto, line 219 */
                int c4 = z->c;
                if (in_grouping_U(z, g_v, 97, 121, 0)) goto lab3;
                z->bra = z->c; /* [, line 219 */
                if (!(eq_s(z, 1, s_83))) goto lab3;
                z->ket = z->c; /* ], line 219 */
                z->c = c4;
                break;
            lab3:
                z->c = c4;
                {   int ret = skip_utf8(z->p, z->c, 0, z->l, 1);
                    if (ret < 0) goto lab2;
                    z->c = ret; /* goto, line 219 */
                }
            }
            {   int ret = slice_from_s(z, 1, s_84); /* <-, line 219 */
                if (ret < 0) return ret;
            }
            z->B[0] = 1; /* set Y_found, line 219 */
            continue;
        lab2:
            z->c = c3;
            break;
        }
        z->c = c2;
    }
    {   int ret = r_measure(z);
        if (ret == 0) return 0; /* call measure, line 221 */
        if (ret < 0) return ret;
    }
    z->lb = z->c; z->c = z->l; /* backwards, line 223 */

    {   int m5 = z->l - z->c; (void)m5; /* do, line 224 */
        {   int ret = r_Step_1(z);
            if (ret == 0) goto lab4; /* call Step_1, line 224 */
            if (ret < 0) return ret;
        }
        z->B[1] = 1; /* set stemmed, line 224 */
    lab4:
        z->c = z->l - m5;
    }
    {   int m6 = z->l - z->c; (void)m6; /* do, line 225 */
        {   int ret = r_Step_2(z);
            if (ret == 0) goto lab5; /* call Step_2, line 225 */
            if (ret < 0) return ret;
        }
        z->B[1] = 1; /* set stemmed, line 225 */
    lab5:
        z->c = z->l - m6;
    }
    {   int m7 = z->l - z->c; (void)m7; /* do, line 226 */
        {   int ret = r_Step_3(z);
            if (ret == 0) goto lab6; /* call Step_3, line 226 */
            if (ret < 0) return ret;
        }
        z->B[1] = 1; /* set stemmed, line 226 */
    lab6:
        z->c = z->l - m7;
    }
    {   int m8 = z->l - z->c; (void)m8; /* do, line 227 */
        {   int ret = r_Step_4(z);
            if (ret == 0) goto lab7; /* call Step_4, line 227 */
            if (ret < 0) return ret;
        }
        z->B[1] = 1; /* set stemmed, line 227 */
    lab7:
        z->c = z->l - m8;
    }
    z->c = z->lb;
    z->B[2] = 0; /* unset GE_removed, line 229 */
    {   int c9 = z->c; /* do, line 230 */
        {   int c10 = z->c; /* and, line 230 */
            {   int ret = r_Lose_prefix(z);
                if (ret == 0) goto lab8; /* call Lose_prefix, line 230 */
                if (ret < 0) return ret;
            }
            z->c = c10;
            {   int ret = r_measure(z);
                if (ret == 0) goto lab8; /* call measure, line 230 */
                if (ret < 0) return ret;
            }
        }
    lab8:
        z->c = c9;
    }
    z->lb = z->c; z->c = z->l; /* backwards, line 231 */

    {   int m11 = z->l - z->c; (void)m11; /* do, line 232 */
        if (!(z->B[2])) goto lab9; /* Boolean test GE_removed, line 232 */
        {   int ret = r_Step_1c(z);
            if (ret == 0) goto lab9; /* call Step_1c, line 232 */
            if (ret < 0) return ret;
        }
    lab9:
        z->c = z->l - m11;
    }
    z->c = z->lb;
    z->B[2] = 0; /* unset GE_removed, line 234 */
    {   int c12 = z->c; /* do, line 235 */
        {   int c13 = z->c; /* and, line 235 */
            {   int ret = r_Lose_infix(z);
                if (ret == 0) goto lab10; /* call Lose_infix, line 235 */
                if (ret < 0) return ret;
            }
            z->c = c13;
            {   int ret = r_measure(z);
                if (ret == 0) goto lab10; /* call measure, line 235 */
                if (ret < 0) return ret;
            }
        }
    lab10:
        z->c = c12;
    }
    z->lb = z->c; z->c = z->l; /* backwards, line 236 */

    {   int m14 = z->l - z->c; (void)m14; /* do, line 237 */
        if (!(z->B[2])) goto lab11; /* Boolean test GE_removed, line 237 */
        {   int ret = r_Step_1c(z);
            if (ret == 0) goto lab11; /* call Step_1c, line 237 */
            if (ret < 0) return ret;
        }
    lab11:
        z->c = z->l - m14;
    }
    z->c = z->lb;
    z->lb = z->c; z->c = z->l; /* backwards, line 239 */

    {   int m15 = z->l - z->c; (void)m15; /* do, line 240 */
        {   int ret = r_Step_7(z);
            if (ret == 0) goto lab12; /* call Step_7, line 240 */
            if (ret < 0) return ret;
        }
        z->B[1] = 1; /* set stemmed, line 240 */
    lab12:
        z->c = z->l - m15;
    }
    {   int m16 = z->l - z->c; (void)m16; /* do, line 241 */
        {   int m17 = z->l - z->c; (void)m17; /* or, line 241 */
            if (!(z->B[1])) goto lab15; /* Boolean test stemmed, line 241 */
            goto lab14;
        lab15:
            z->c = z->l - m17;
            if (!(z->B[2])) goto lab13; /* Boolean test GE_removed, line 241 */
        }
    lab14:
        {   int ret = r_Step_6(z);
            if (ret == 0) goto lab13; /* call Step_6, line 241 */
            if (ret < 0) return ret;
        }
    lab13:
        z->c = z->l - m16;
    }
    z->c = z->lb;
    {   int c18 = z->c; /* do, line 243 */
        if (!(z->B[0])) goto lab16; /* Boolean test Y_found, line 243 */
        while(1) { /* repeat, line 243 */
            int c19 = z->c;
            while(1) { /* goto, line 243 */
                int c20 = z->c;
                z->bra = z->c; /* [, line 243 */
                if (!(eq_s(z, 1, s_85))) goto lab18;
                z->ket = z->c; /* ], line 243 */
                z->c = c20;
                break;
            lab18:
                z->c = c20;
                {   int ret = skip_utf8(z->p, z->c, 0, z->l, 1);
                    if (ret < 0) goto lab17;
                    z->c = ret; /* goto, line 243 */
                }
            }
            {   int ret = slice_from_s(z, 1, s_86); /* <-, line 243 */
                if (ret < 0) return ret;
            }
            continue;
        lab17:
            z->c = c19;
            break;
        }
    lab16:
        z->c = c18;
    }
    return 1;
}

extern struct SN_env * kraaij_pohlmann_UTF_8_create_env(void) { return SN_create_env(1, 3, 3); }

extern void kraaij_pohlmann_UTF_8_close_env(struct SN_env * z) { SN_close_env(z, 1); }

