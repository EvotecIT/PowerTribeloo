---
external help file: PowerTribeloo-help.xml
Module Name: PowerTribeloo
online version:
schema: 2.0.0
---

# Get-TribelooUser

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-TribelooUser [[-Id] <String>] [[-SearchUserName] <String>] [[-SearchExternalID] <String>]
 [[-Search] <String>] [[-SearchProperty] <String>] [[-SearchOperator] <String>] [[-MaxResults] <Int32>]
 [[-Filter] <String>] [[-SortBy] <String>] [[-SortOrder] <String>] [-Native] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Filter
{{ Fill Filter Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
{{ Fill Id Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxResults
{{ Fill MaxResults Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Native
{{ Fill Native Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Search
{{ Fill Search Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchExternalID
{{ Fill SearchExternalID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: ExternalID

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchOperator
{{ Fill SearchOperator Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchProperty
{{ Fill SearchProperty Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: id, userName, givenName, familyName, displayName, nickName, emails, addresses, meta

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchUserName
{{ Fill SearchUserName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserName

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy
{{ Fill SortBy Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: id, userName, givenName, familyName, displayName, nickName, emails, addresses, meta

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortOrder
{{ Fill SortOrder Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ascending, descending

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
