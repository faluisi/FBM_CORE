pageextension 60162 FBM_SalesInvExt_CO extends "Sales Invoice"
{
    layout
    {
        modify("Sell-to Customer No.")
        {
            trigger
            OnAfterValidate()
            var
                mediaid: Guid;
            begin
                if usersetup.get(UserId) then begin
                    mediaid := usersetup."Signature PHL".Item(1);
                    rec.FBM_Signature_pic.Insert(mediaid);
                    rec.Modify();

                end;

            end;
        }
        addafter("External Document No.")
        {
            field("Posting No."; rec."Posting No.")
            {
                ApplicationArea = All;
            }
            field(Site; rec.FBM_Site)
            {
                ApplicationArea = All;

                trigger OnLookup(var Text: Text): Boolean
                var
                    CustSite: Record FBM_CustomerSite_C;
                    CustSiteFull: Record FBM_CustomerSite_C;
                    FASetup: Record "FA Setup";
                    companyinfo: record "Company Information";
                    CustmoerSiteP: Page FBM_CustomerSite_CO;
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
                            /*CustmoerSiteP.Editable := false;
                                            if CustmoerSiteP.RunModal = Action::LookupOK then
                                                Rec.Validate(Site, CustSite."Site Code");*/
                        end
                    end
                    else begin
                        CustSite.SetFilter(CustSite."Customer No.", rec."Sell-to Customer No.");
                        if CustSite.FindFirst() then begin
                            if page.RunModal(60101, CustSite) = Action::LookupOK then Rec.Validate(fbm_Site, CustSite."Site Code");
                        end
                        else begin
                            if page.RunModal(60101, CustSiteFull) = Action::LookupOK then Rec.Validate(fbm_Site, CustSiteFull."Site Code");
                        end;
                    end;
                    CurrPage.Update(true);
                end;

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }

            field("Contract Code"; rec."FBM_Contract Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(Segment; rec.FBM_Segment)
            {
                ApplicationArea = All;
            }

            field("Period Start"; rec."FBM_Period Start")
            {
                ApplicationArea = all;
            }
            field("Period End"; rec.FBM_LocalCurrAmt)
            {
                ApplicationArea = all;
            }
            field(signature_pic; rec.FBM_Signature_pic)
            {
                ApplicationArea = all;
            }


            field("Billing Statement"; rec."FBM_Billing Statement")
            {
                ApplicationArea = all;
            }

        }
        addlast(General)
        {
            field(LocalCurrAmt; rec.FBM_LocalCurrAmt)
            {
                ApplicationArea = all;

            }
            field(Currency2; rec.FBM_Currency2)
            {
                ApplicationArea = all;

            }

        }
        addafter("Currency Code")
        {
            field("Customer Payment Bank Code"; rec."FBM_Cust Payment Bank Code")
            {
                ApplicationArea = all;
                Editable = false;
            }

            field("Customer Payment Bank Code2"; rec."FBM_Cust Payment Bank Code2")
            {
                ApplicationArea = all;
                Editable = false;
            }

        }
        modify("Company Bank Account Code")
        {

            Visible = false;
        }
        addlast(factboxes)
        {

            part(signature; FBM_Factbox_SI_CO)
            {

                SubPageLink = "No." = field("No.");
            }
        }

    }


    actions
    {
    }
    var
        usersetup: record "User Setup";
}