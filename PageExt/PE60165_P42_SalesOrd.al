pageextension 60165 FBM_SalesOrdExt_CO extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field(FBM_Site; Rec.FBM_Site)
            {
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
                        if CustSite.FindFirst() then begin
                            if page.RunModal(50001, CustSite) = Action::LookupOK then Rec.Validate(fbm_Site, CustSite."Site Code");
                        end
                    end
                    else begin
                        CustSite.SetFilter(CustSite."Customer No.", rec."Sell-to Customer No.");
                        if CustSite.FindFirst() then begin
                            if page.RunModal(50001, CustSite) = Action::LookupOK then Rec.Validate(fbm_Site, CustSite."Site Code");
                        end
                        else begin
                            if page.RunModal(50001, CustSiteFull) = Action::LookupOK then Rec.Validate(fbm_Site, CustSiteFull."Site Code");
                        end;
                    end;
                    CurrPage.Update(true);
                end;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }

            field("FBM_Contract Code"; Rec."FBM_Contract Code")
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

        }
    }

}