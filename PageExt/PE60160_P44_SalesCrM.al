pageextension 60160 SalesCreditMemoExt extends "Sales Credit Memo"
{
    layout
    {
        addafter("External Document No.")
        {
            field(FBM_Site; Rec.FBM_Site)
            {
                Visible = showsite;
                ApplicationArea = All;

                trigger OnLookup(var Text: Text): Boolean
                var
                    CustSite: Record FBM_CustomerSite_C;
                    CustSiteFull: Record FBM_CustomerSite_C;
                    FASetup: Record "FA Setup";
                    companyinfo: record "Company Information";
                begin
                    CustSite.Reset();
                    FASetup.Get();
                    CustSiteFull.Reset();
                    companyinfo.Reset();
                    companyinfo.Get();
                    if companyinfo.FBM_CustIsOp then begin
                        CustSite.SetFilter(CustSite."Customer No.", rec."Sell-to Customer No.");
                        CustSite.SetRange(ActiveRec, true);
                        if CustSite.FindFirst() then begin
                            if page.RunModal(60167, CustSite) = Action::LookupOK then Rec.Validate(fbm_site, CustSite."Site Code");
                        end
                    end
                    else begin
                        CustSite.SetFilter(CustSite."Customer No.", rec."Sell-to Customer No.");
                        CustSite.SetRange(ActiveRec, true);
                        if CustSite.FindFirst() then begin
                            if page.RunModal(60167, CustSite) = Action::LookupOK then Rec.Validate(fbm_site, CustSite."Site Code");
                        end
                        else begin
                            if page.RunModal(60167, CustSiteFull) = Action::LookupOK then Rec.Validate(fbm_site, CustSiteFull."Site Code");
                        end;
                    end;
                    CurrPage.Update(true);
                end;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }

            field("FBM_Contract Code"; rec."FBM_Contract Code")
            {
                ApplicationArea = All;
            }

            field("FBM_Period Start"; Rec."FBM_Period Start")
            {
                ApplicationArea = all;
            }
            field("FBM_Period End"; Rec."FBM_Period End")
            {
                ApplicationArea = all;
            }
            field(FBM_Segment; Rec.FBM_Segment2)
            {
                ApplicationArea = all;
            }

        }
        addlast(General)
        {
            field(Currency2; rec.FBM_Currency2)
            {
                ApplicationArea = all;

            }
            field(LocalCurrAmt; rec.FBM_LocalCurrAmt)
            {
                ApplicationArea = all;

            }

            field(LCY; glsetup."LCY Code")
            {
                ApplicationArea = All;
                Editable = false;
            }

        }
    }
    trigger
       OnOpenPage()
    begin
        compinfo.Get();
        showsite := compinfo.FBM_CustIsOp;
        glsetup.Get();

    end;




    var

        compinfo: record "Company Information";
        showsite: Boolean;
        glsetup: record "General Ledger Setup";
}
