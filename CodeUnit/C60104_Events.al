codeunit 60104 FBM_Events_CO
{
    Permissions = tabledata 32 = rimd, tabledata "Sales Cr.Memo Header" = rimd;
    ;
    EventSubscriberInstance = StaticAutomatic;

    var
        FormatAddress: Codeunit "Format Address";

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnSubstituteReport(ReportId: Integer; var NewReportId: Integer)
    begin
        if ReportId = 393 then
            NewReportId := 60134;
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnLookUpAppliesToDocVendOnAfterSetFilters', '', false, false)]
    local procedure OnLookUpAppliesToDocVendOnAfterSetFilters(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; AccNo: Code[20])
    begin
        // VendorLedgerEntry.SetRange(FBM_approved, true);
        // VendorLedgerEntry.SetRange(FBM_approved1, true);
        // VendorLedgerEntry.SetRange(FBM_approved2, true);

    end;

    [IntegrationEvent(false, false)]
    procedure OnReasonCodeChanged(currpage: Page "FBM_PayJnl Bank List Part_CO");
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure AssignDocDimSetEntryValue(var SalesHeader: Record "Sales Header")//procedure to create Dim. Set Entries for Sales Doc. being posted
    var
        FASetup: Record "FA Setup";
        DimMgmt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        Text000: label 'There are  start/end dates and no Site, please amend. Line %1';
        salesline: record "Sales Line";
    begin
        // salesline.SetRange("Document Type", SalesHeader."Document Type");
        // salesline.SetRange("Document No.", SalesHeader."No.");
        // if salesline.FindFirst() then
        //     repeat
        //         if ((salesline."FBM_Period Start" <> 0D) or (salesline."FBM_Period End" <> 0D)) and (salesline.FBM_Site = '') then
        //             error(Text000, salesline."Line No.");
        //     until salesline.next = 0;
        FASetup.Get();
        if FASetup."FBM_Enable FA Site Tracking" then begin
            DimMgmt.GetDimensionSet(TempDimSetEntry, SalesHeader."Dimension Set ID");
            DimVal.Reset();
            if DimVal.get(FASetup."FBM_Site Dimension", SalesHeader.FBM_Site) then begin
                TempDimSetEntry.Init();
                //TempDimSetEntry."Dimension Set ID" := DimMgmt.GetDimensionSetID(TempDimSetEntry);
                TempDimSetEntry."Dimension Code" := FASetup."FBM_Site Dimension";
                TempDimSetEntry."Dimension Value Code" := SalesHeader.FBM_Site;
                TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                TempDimSetEntry.Insert();
                SalesHeader."Dimension Set ID" := DimMgmt.GetDimensionSetID(TempDimSetEntry);
                SalesHeader.Modify();
            end;
            CLEAR(TempDimSetEntry);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure AssignContractDocDimSetEntryValue(var SalesHeader: Record "Sales Header")//procedure to create Dim. Set Entries for Sales Doc. being posted
    var
        FASetup: Record "FA Setup";
        DimMgmt: Codeunit DimensionManagement;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DSE_C: Record "Dimension Set Entry";
        salessetup: Record "Sales & Receivables Setup";
    begin
        salessetup.Get();
        if (salessetup."FBM_Period Start End mandatory") then begin
            // SalesHeader.TestField("Period Start");
            // SalesHeader.TestField("Period End");

            if (SalesHeader."FBM_Period Start" = 0D) then
                Error('Period start is mandatory');
            if (SalesHeader."FBM_Period End" = 0D) then
                Error('Period end is mandatory');

            FASetup.Get();
            DSE_C.Reset();
            if not DSE_C.Get(SalesHeader."Dimension Set ID", FASetup."FBM_Contract Dimension") then begin
                if FASetup."FBM_Enable FA Site Tracking" then begin
                    DimMgmt.GetDimensionSet(TempDimSetEntry, SalesHeader."Dimension Set ID");
                    DimVal.Reset();
                    if DimVal.get(FASetup."FBM_Contract Dimension", SalesHeader."FBM_Contract Code") then begin
                        TempDimSetEntry.Init();
                        TempDimSetEntry."Dimension Code" := FASetup."FBM_Contract Dimension";
                        TempDimSetEntry."Dimension Value Code" := SalesHeader."FBM_Contract Code";
                        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
                        TempDimSetEntry.Insert();
                        SalesHeader."Dimension Set ID" := DimMgmt.GetDimensionSetID(TempDimSetEntry);
                        SalesHeader.Modify();
                    end;
                    CLEAR(TempDimSetEntry);
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', true, true)]
    local procedure "Gen. Journal Line_OnAfterCopyGenJnlLineFromSalesHeader"(SalesHeader: Record "Sales Header";
    var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."FBM_Period Start" := SalesHeader."FBM_Period Start";
        GenJournalLine."FBM_Period End" := SalesHeader."FBM_Period End";
        GenJournalLine.FBM_Segment := SalesHeader.FBM_Segment;
        GenJournalLine.FBM_Site := SalesHeader.FBM_Site;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitGLEntry"(var GLEntry: Record "G/L Entry";
    GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        GLEntry."FBM_Period End" := GenJournalLine."FBM_Period End";

        GLEntry.FBM_Segment := GenJournalLine.FBM_Segment;
        GLEntry.FBM_Site := GenJournalLine.FBM_Site;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterHandleAddCurrResidualGLEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnAfterHandleAddCurrResidualGLEntry"(GenJournalLine: Record "Gen. Journal Line";
    GLEntry2: Record "G/L Entry")
    begin
        GLEntry2."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        GLEntry2."FBM_Period End" := GenJournalLine."FBM_Period End";
        GLEntry2.FBM_Segment := GenJournalLine.FBM_Segment;
        GLEntry2.FBM_Site := GenJournalLine.FBM_Site;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeInsertGLEntryBuffer"(var TempGLEntryBuf: Record "G/L Entry";
    var GenJournalLine: Record "Gen. Journal Line";
    var BalanceCheckAmount: Decimal;
    var BalanceCheckAmount2: Decimal;
    var BalanceCheckAddCurrAmount: Decimal;
    var BalanceCheckAddCurrAmount2: Decimal;
    var NextEntryNo: Integer)
    begin
        TempGLEntryBuf."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        TempGLEntryBuf."FBM_Period End" := GenJournalLine."FBM_Period End";
        TempGLEntryBuf.FBM_Segment := GenJournalLine.FBM_Segment;
        TempGLEntryBuf.FBM_Site := GenJournalLine.FBM_Site;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', true, true)]
    local procedure "Cust. Ledger Entry_OnAfterCopyCustLedgerEntryFromGenJnlLine"(var CustLedgerEntry: Record "Cust. Ledger Entry";
    GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        CustLedgerEntry."FBM_Period End" := GenJournalLine."FBM_Period End";
        CustLedgerEntry.FBM_Segment := GenJournalLine.FBM_Segment;
        CustLedgerEntry.FBM_Site := GenJournalLine.FBM_Site;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitCustLedgEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnAfterInitCustLedgEntry"(var CustLedgerEntry: Record "Cust. Ledger Entry";
    GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        CustLedgerEntry."FBM_Period End" := GenJournalLine."FBM_Period End";
        CustLedgerEntry.FBM_Segment := GenJournalLine.FBM_Segment;
        CustLedgerEntry.FBM_Site := GenJournalLine.FBM_Site;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldCustLedgEntry', '', true, true)]
    local procedure "Gen. Jnl.-Post Line_OnBeforeInsertDtldCustLedgEntry"(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    GenJournalLine: Record "Gen. Journal Line";
    DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    begin
        DtldCustLedgEntry."FBM_Period Start" := GenJournalLine."FBM_Period Start";
        DtldCustLedgEntry."FBM_Period End" := GenJournalLine."FBM_Period End";
        DtldCustLedgEntry.FBM_Segment := GenJournalLine.FBM_Segment;
        DtldCustLedgEntry.FBM_Site := GenJournalLine.FBM_Site;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTempPrepmtPurchLineInsert', '', false, false)]
    local procedure SetAmt
    (
        var TempPrepmtPurchLine: Record "Purchase Line" temporary;
    var TempPurchLine: Record "Purchase Line" temporary; PurchaseHeader: Record "Purchase Header"; CompleteFunctionality: Boolean
    )

    begin
        TempPrepmtPurchLine."Prepmt Amt to Deduct" := TempPurchLine."Prepmt Amt to Deduct";
        TempPrepmtPurchLine."Prepmt. Amt. Inv." := TempPurchLine."Prepmt. Amt. Inv.";
        TempPrepmtPurchLine."Prepmt. Amt. Incl. VAT" := TempPurchLine."Prepmt. Amt. Incl. VAT";



    end;


    [EventSubscriber(ObjectType::Codeunit, 60104, 'OnReasonCodeChanged', '', true, true)]
    procedure RefreshBanksList(currpage: Page "FBM_PayJnl Bank List Part_CO");
    begin
        currpage.Update(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 231, 'OnBeforeCode', '', true, true)]
    procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean);
    begin
        if GenJournalLine.FindSet() then begin
            if GenJournalLine."Journal Batch Name" = 'APPROVALS' then begin
                // Message('APPROVALS');
                GenJournalLine.SetRange("Reason Code", 'APPROVED');

            end;

        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 13, 'OnAfterCode', '', true, true)]
    procedure OnAfterCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean);
    begin
        // GenJournalLine.SetRange("Reason Code", 'REJECTED');
        // if GenJournalLine.FindSet() then begin
        // if GenJournalLine."Journal Batch Name" = 'APPROVALS' then begin
        // Message('APPROVALS');

        // GenJournalLine.DeleteAll();

        // end;

        // end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnPostUpdateOrderLineOnAfterReceive', '', true, true)]
    procedure OnAfterProcessPurchLines(var PurchHeader: Record "Purchase Header"; var TempPurchLine: Record "Purchase Line" temporary);
    var
        purchline: record "Purch. Inv. Line";
        itemtrack: record "Tracking Specification";
        fa: record "Fixed Asset";
    begin
        if PurchHeader.Receive then begin
            itemtrack.SetRange("Source ID", PurchHeader."No.");
            itemtrack.SetRange("Source Type", 39);
            itemtrack.SetRange("Source Subtype", 1);
            if itemtrack.FindFirst() then
                repeat
                    if itemtrack."Serial No." <> '' then begin
                        fa.SetRange("Serial No.", itemtrack."Serial No.");
                        if fa.FindFirst() then begin
                            fa.FBM_Status := fa.FBM_Status::"C. stock";
                            fa.Modify();
                        end
                    end;
                until itemtrack.Next() = 0


        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 5856, 'OnAfterCreateItemJnlLine', '', true, true)]
    procedure OnAfterCreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; TransLine: Record "Transfer Line"; DirectTransHeader: Record "Direct Trans. Header"; DirectTransLine: Record "Direct Trans. Line")
    begin
        if ItemJnlLine.Quantity < 0 then
            ItemJnlLine.FBM_Site := DirectTransHeader.FBM_SiteFrom
        else
            ItemJnlLine.FBM_Site := DirectTransHeader.FBM_SiteTo;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5856, 'OnAfterInsertDirectTransHeader', '', true, true)]
    procedure OnAfterInsertDirectTransHeader(var DirectTransHeader: Record "Direct Trans. Header"; TransferHeader: Record "Transfer Header")
    begin
        DirectTransHeader.FBM_SiteFrom := TransferHeader.FBM_SiteFrom;
        DirectTransHeader.FBM_SiteTo := TransferHeader.FBM_SiteTo;

    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterPostItemJnlLine', '', true, true)]
    procedure OnAfterPostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean; CalledFromInvtPutawayPick: Boolean; var ItemRegister: Record "Item Register"; var ItemLedgEntryNo: Integer; var ItemApplnEntryNo: Integer)
    var
        itemLE: record "Item Ledger Entry";
        resentry: record "Reservation Entry";
    begin
        if itemLE.get(ItemJournalLine."Item Shpt. Entry No.") then begin
            itemLE.FBM_Site := ItemJournalLine.FBM_Site;
            itemLE.Modify();
            resentry.SetRange("Item Ledger Entry No.", itemLE."Entry No.");
            if resentry.FindFirst() then begin
                resentry.FBM_Site := ItemJournalLine.FBM_Site;
                resentry.Modify();
            end;

        end;
        if itemLE.get(ItemLedgEntryNo) then begin
            itemLE.FBM_Site := ItemJournalLine.FBM_Site;
            itemLE.Modify();
            resentry.SetRange("Item Ledger Entry No.", itemLE."Entry No.");
            if resentry.FindFirst() then begin
                resentry.FBM_Site := ItemJournalLine.FBM_Site;
                resentry.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5705, 'OnBeforePostItemJournalLine', '', true, true)]

    procedure OnBeforePostItemJournalLineR(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferReceiptHeader: Record "Transfer receipt Header"; TransferReceiptLine: Record "Transfer Receipt Line"; CommitIsSuppressed: Boolean)
    var
        traheader: record "Transfer Header";
    begin
        if traheader.get(TransferLine."Document No.") then begin
            ItemJournalLine.FBM_Site := traheader.FBM_SiteTo;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5704, 'OnBeforePostItemJournalLine', '', true, true)]

    procedure OnBeforePostItemJournalLineS(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLine: Record "Transfer Shipment Line"; CommitIsSuppressed: Boolean)
    var
        traheader: record "Transfer Header";
    begin
        if traheader.get(TransferLine."Document No.") then begin
            ItemJournalLine.FBM_Site := traheader.FBM_SiteFrom;

        end;
    end;



    [EventSubscriber(ObjectType::Table, 83, 'OnAfterCopyItemJnlLineFromPurchLine', '', true, true)]
    procedure OnAfterCopyItemJnlLineFromPurchLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        ItemJnlLine.FBM_Site := PurchLine.FBM_Site;

    end;

    [EventSubscriber(ObjectType::Table, 5740, 'OnUpdateTransLines', '', true, true)]
    procedure OnUpdateTransLines(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; FieldID: Integer)
    begin
        TransferLine.FBM_SiteFrom := TransferHeader.FBM_SiteFrom;
        TransferLine.FBM_SiteTo := TransferHeader.FBM_SiteTo;

    end;

    [EventSubscriber(ObjectType::Codeunit, 5400, 'OnAfterCalcAvailableQty', '', true, true)]
    procedure OnAfterCalcAvailableQty(var Item: Record Item; CalcAvailable: Boolean; PlannedOrderReceiptDate: Date; var AvailableQty: Decimal)
    begin
        item.CalcFields(Inventory, FBM_Inventory_FF);
        AvailableQty := AvailableQty - item.Inventory;
        AvailableQty := AvailableQty + item.FBM_Inventory_FF;

    end;

    [EventSubscriber(ObjectType::Codeunit, 5790, 'OnAfterCalcAvailableInventory', '', true, true)]
    procedure OnAfterCalcAvailableInventory(var Item: Record Item; var AvailableInventory: Decimal)
    begin
        item.CalcFields(Inventory, FBM_Inventory_FF);
        AvailableInventory := AvailableInventory - item.Inventory;
        AvailableInventory := AvailableInventory + item.FBM_Inventory_FF;
    end;
    //format address

    procedure GetCompanyAddrCountry(RespCenterCode: Code[10];
    var ResponsibilityCenter: Record "Responsibility Center";
    var CompanyInfo: Record "Company Information";
    var CompanyAddr: array[8] of Text[100])
    begin
        if ResponsibilityCenter.Get(RespCenterCode) then begin
            RespCenterCountry(CompanyAddr, ResponsibilityCenter);
            CompanyInfo."Phone No." := ResponsibilityCenter."Phone No.";
            CompanyInfo."Fax No." := ResponsibilityCenter."Fax No.";
        end
        else
            CompanyCountry(CompanyAddr, CompanyInfo);
    end;

    procedure CompanyCountry(var AddrArray: array[8] of Text[100];
    var CompanyInfo: Record "Company Information")
    begin
        FormatAddress.FormatAddr(AddrArray, CompanyInfo.Name, CompanyInfo."Name 2", '', CompanyInfo.Address, CompanyInfo."Address 2", CompanyInfo.City, CompanyInfo."Post Code", CompanyInfo.County, CompanyInfo."Country/Region Code");
    end;

    procedure RespCenterCountry(var AddrArray: array[8] of Text[100];
    var RespCenter: Record "Responsibility Center")
    begin
        FormatAddress.FormatAddr(AddrArray, RespCenter.Name, RespCenter."Name 2", RespCenter.Contact, RespCenter.Address, RespCenter."Address 2", RespCenter.City, RespCenter."Post Code", RespCenter.County, RespCenter."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Format Address", 'OnBeforeSalesInvSellTo', '', true, true)]
    procedure OnBeforeSalesInvSellTo(var AddrArray: array[8] of Text[100]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var Handled: Boolean)
    var
        format: codeunit "Format Address";
    begin

        format.FormatAddr(
          AddrArray, SalesInvoiceHeader."Sell-to Customer Name", SalesInvoiceHeader."Sell-to Customer Name 2", '', SalesInvoiceHeader."Sell-to Address", SalesInvoiceHeader."Sell-to Address 2",
          SalesInvoiceHeader."Sell-to City", SalesInvoiceHeader."Sell-to Post Code", SalesInvoiceHeader."Sell-to County", SalesInvoiceHeader."Sell-to Country/Region Code");
        Handled := true;
    end;



}
