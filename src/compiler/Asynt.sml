local
  open Fnlib Mixture Const Globals Location Types;
in

datatype IdKindDesc =
    VARik 
  | FUNik
  | STRik
  | PRIMik of PrimInfo
  | CONik of ConInfo
  | EXCONik of ExConInfo
;

type IdKind = IdKindDesc global;

type IdDesc =
{
  idLoc : Location,
  withOp : bool,
  idKind : IdKind ref,
  idFields: int list ref
};

type IdInfo = IdDesc global;

(* Identifiers *)

type LocString = Location * string;

type VId = LocString;  (* this should really just be string... *)
type TyCon = LocString; (* this should really just be Locstring... *) 

type ModId = LocString;
type FunId = LocString;
type SigId = LocString;

type LongModId = IdInfo;
type LongModIdInfo = IdInfo * ((Environment option) ref);
type LongVId = IdInfo;
type LongTyCon = IdInfo;

type TyVar = IdInfo; 
type TyVarSeq = TyVar list;


datatype TyConPath' =  
    LONGtyconpath of LongTyCon
  | WHEREtyconpath of LongTyCon * ModId * ModExp               
   
and Ty' =
    TYVARty of TyVar
  | RECty of Ty Row
  | CONty of Ty list * TyConPath
  | FNty of Ty * Ty
  | PACKty of SigExp 


and InfixPat =
    UNRESinfixpat of Pat list 
  | RESinfixpat of Pat
and Pat' =
    SCONpat of SCon * Type option ref
  | VARpat of LongVId
  | WILDCARDpat
  | NILpat of LongVId
  | CONSpat of LongVId * Pat
  | EXNILpat of LongVId
  | EXCONSpat of LongVId * Pat
  | EXNAMEpat of LongVId         (* This is a hack to be used in match(.sml) *)
  | REFpat of Pat
  | RECpat of RecPat ref
  | VECpat of Pat list
  | INFIXpat of InfixPat ref
  | PARpat of Pat
  | TYPEDpat of Pat * Ty
  | LAYEREDpat of Pat * Pat

and RecPat =
    RECrp of Pat Row * RowType option
  | TUPLErp of Pat list

(* cvr: the current definitions of VIdPathInfo and
        VIdPath' are to liberal since a DOTvidpath should never
        be overloaded --- remember to tidy this up if possible 
*)

and VIdPathInfo =
    RESvidpath of VIdPath'
  | OVLvidpath of VIdPath' * OvlType * Type
and VIdPath' = 
    LONGvidpath of LongVId
  | WHEREvidpath of LongVId * ModId * ModExp

and InfixExp =
    UNRESinfixexp of Exp list 
  | RESinfixexp of Exp
and Exp' =
    SCONexp of SCon * Type option ref
  | VIDPATHexp of VIdPathInfo ref
  | RECexp of RecExp ref
  | VECexp of Exp list
  | LETexp of Dec * Exp
  | PARexp of Exp
  | APPexp of Exp * Exp
  | INFIXexp of InfixExp ref
  | TYPEDexp of Exp * Ty
  | ANDALSOexp of Exp * Exp
  | ORELSEexp of Exp * Exp
  | HANDLEexp of Exp * Match
  | RAISEexp of Exp
  | IFexp of Exp * Exp * Exp
  | WHILEexp of Exp * Exp
  | FNexp of Match
  | SEQexp of Exp * Exp
  | STRUCTUREexp of ModExp * SigExp * (ExMod option) ref
  | FUNCTORexp of ModExp * SigExp * (ExMod option) ref

and RecExp =
    RECre of Exp Row
  | TUPLEre of Exp list

and MRule = MRule of (Pat list ref) * Exp

and FunDec = 
    UNRESfundec of TyVarSeq *  (FValBind list)
  | RESfundec of Dec
               
and Dec' =
    VALdec of TyVarSeq * (ValBind list * ValBind list)
  | PRIM_VALdec of TyVarSeq * (PrimValBind list)
  | FUNdec of FunDec ref
  | TYPEdec of TypBind list
  | PRIM_TYPEdec of TyNameEqu * TypDesc list
  | DATATYPEdec of DatBind list * TypBind list option
  | DATATYPErepdec of TyVarSeq * TyCon * TyVarSeq * TyConPath
  | ABSTYPEdec of DatBind list * TypBind list option * Dec
  | EXCEPTIONdec of ExBind list
  | LOCALdec of Dec * Dec
  | OPENdec of LongModIdInfo list
  | STRUCTUREdec of ModBind list
  | FUNCTORdec of FunBind list
  | SIGNATUREdec of SigBind list
  | EMPTYdec
  | SEQdec of Dec * Dec
  | FIXITYdec of InfixStatus * string list

and ValBind = ValBind of (Pat ref) * Exp

and FClause = FClause of (Pat list ref) * Exp

and ConBind = ConBind of IdInfo * Ty option

and ExBind =
    EXDECexbind of IdInfo * Ty option
  | EXEQUALexbind of IdInfo * IdInfo

and ModBind = MODBINDmodbind of ModId * ModExp
            | ASmodbind of ModId * SigExp * Exp
and FunBind = 
              FUNBINDfunbind of FunId * ModExp
            | ASfunbind of FunId * SigExp * Exp
and SigBind = SIGBINDsigbind of SigId * SigExp
and FunctorSort = 
    Generative of bool (* true if conforms to SML 97 *)
  | Applicative
and ModExp' = 
    DECmodexp of Dec
  | LONGmodexp of LongModId
  | WHEREmodexp of LongModId * ModId * ModExp
  | LETmodexp of Dec * ModExp 
  | PARmodexp of ModExp
  | CONmodexp of ModExp *  SigExp
  | ABSmodexp of ModExp *  SigExp
  | FUNCTORmodexp of FunctorSort *  ModId * (IdKindDesc ref) * SigExp * ModExp
  | APPmodexp of ModExp * ModExp
and ModDesc = MODDESCmoddesc of ModId * SigExp
and FunDesc = FUNDESCfundesc of FunId * SigExp
and SigExp' = 
    SPECsigexp of Spec
  | SIGIDsigexp of SigId
  | WHEREsigexp of SigExp * TyVarSeq * LongTyCon * Ty
  | FUNSIGsigexp of FunctorSort * ModId * SigExp * SigExp
and Spec' =
    VALspec of TyVarSeq * ValDesc list
  | PRIM_VALspec of TyVarSeq * (PrimValBind list)
  | TYPEDESCspec of TyNameEqu * TypDesc list
  | TYPEspec of TypBind list
  | DATATYPEspec of DatBind list * TypBind list option
  | DATATYPErepspec of TyVarSeq * TyCon * TyVarSeq * TyConPath
  | EXCEPTIONspec of ExDesc list
  | LOCALspec of Spec * Spec
  | OPENspec of LongModIdInfo list
  | EMPTYspec
  | SEQspec of Spec * Spec
  | INCLUDEspec of SigExp
  | STRUCTUREspec of ModDesc list
  | FUNCTORspec of FunDesc list
  | SHARINGTYPEspec of Spec * LongTyCon list
  | SHARINGspec of Spec * (Location * LongModId list)
 

and Sig = 
    NamedSig of {locsigid : SigId, specs : Spec list}
  | AnonSig of Spec list

and Struct =
    NamedStruct of {locstrid : ModId, locsigid : SigId option,
		    decs : Dec list}
  | Abstraction of {locstrid : ModId, locsigid : SigId, 
		    decs : Dec list}
  | AnonStruct of Dec list

withtype TyConPath = Location * TyConPath'
and Ty = Location * Ty'
and Pat = Location * Pat'
and VIdPath = Location * VIdPath'
and Exp = Location * Exp'
and ModExp = Location * (ModExp' * (ExMod option) ref)
and SigExp = Location * SigExp'
and Spec = Location * Spec'
and ValDesc = IdInfo * (Location * Ty') 
           (* IdInfo * Ty *)
and ExDesc = IdInfo * (Location * Ty') option 
          (* IdInfo * Ty option *)
and LocString = Location * string
and Match = MRule list
and Dec = Location * Dec'
and PrimValBind = IdInfo * (Location * Ty') * int * string 
               (* IdInfo * Ty * int * string *)
and FValBind = Location * FClause list
and TypBind = TyVarSeq * TyCon * (Location * Ty')
           (* TyVar list * IdInfo * Ty *)
and TypDesc = TyVarSeq * TyCon
and DatBind = TyVarSeq * TyCon * ConBind list



end;


























