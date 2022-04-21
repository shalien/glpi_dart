/// The enum reference all the GLPI itemtype inherited from the GLPI class [CommonDBTM](https://forge.glpi-project.org/apidoc/class-CommonDBTM.html).
/// This mean we will keep the GLPI / PHP naming convention for the itemtype.
// ignore_for_file: constant_identifier_names
enum GlpiItemType {
  /// APIClient
  APIClient,

  ///Alert
  Alert,

  ///AllAssets
  ///Represent AllAssets of GLPI , used only in the search method
  AllAssets,

  ///AuthLDAP
  AuthLDAP,

  ///AuthLdapReplicate
  AuthLdapReplicate,

  ///AuthMail
  AuthMail,

  ///AuthMailMessage
  AutoUpdateSystem,

  ///Blacklist
  Blacklist,

  ///BlacklistedMailContent
  BlacklistedMailContent,

  ///Budget
  Budget,

  ///BudgetType
  BudgetType,

  ///BusinessCriticity
  BusinessCriticity,

  ///Calendar
  Calendar,

  ///CalendarSegment
  CalendarSegment,

  ///Calendar_Holiday
  Calendar_Holiday,

  ///Cartridge
  Cartridge,

  ///CartridgeItem
  CartridgeItem,

  ///CartridgeItemType
  CartridgeItemType,

  ///CartridgeItem_PrinterModel
  CartridgeItem_PrinterModel,

  ///Certificate
  Certificate,

  ///CertificateType
  CertificateType,

  ///Certificate_Item
  Certificate_Item,

  ///Change
  Change,

  ///ChangeCost
  ChangeCost,

  ///ChangeTask
  ChangeTask,

  ///ChangeValidation
  ChangeValidation,

  ///Change_Group
  Change_Group,

  ///Change_Item
  Change_Item,

  ///Change_Problem
  Change_Problem,

  ///Change_Supplier
  Change_Supplier,

  ///Change_Ticket
  Change_Ticket,

  ///Change_User
  Change_User,

  ///CommonDBChild
  CommonDBChild,

  ///CommonDBConnexity
  CommonDBConnexity,

  ///CommonDBRelation
  CommonDBRelation,

  ///CommonDBVisible
  CommonDBVisible,

  ///CommonDCModelDropdown
  CommonDCModelDropdown,

  ///CommonDevice
  CommonDevice,

  ///CommonDeviceModel
  CommonDeviceModel,

  ///CommonDeviceType
  CommonDeviceType,

  ///CommonDropdown
  CommonDropdown,

  ///CommonITILActor
  CommonITILActor,

  ///CommonITILCost
  CommonITILCost,

  ///CommonITILObject
  CommonITILObject,

  ///CommonITILTask
  CommonITILTask,

  ///CommonITILValidation
  CommonITILValidation,

  ///CommonImplicitTreeDropdown
  CommonImplicitTreeDropdown,

  ///CommonTreeDropdown
  CommonTreeDropdown,

  ///Computer
  Computer,

  ///ComputerAntivirus
  ComputerAntivirus,

  ///ComputerModel
  ComputerModel,

  ///ComputerType
  ComputerType,

  ///ComputerVirtualMachine
  ComputerVirtualMachine,

  ///Computer_Item
  Computer_Item,

  ///Computer_SoftwareLicense
  Computer_SoftwareLicense,

  ///Computer_SoftwareVersion
  Computer_SoftwareVersion,

  ///Config
  Config,

  ///Consumable
  Consumable,

  ///ConsumableItem
  ConsumableItem,

  ///ConsumableItemType
  ConsumableItemType,

  ///Contact
  Contact,

  ///ContactType
  ContactType,

  ///Contact_Supplier
  Contact_Supplier,

  ///Contract
  Contract,

  ///ContractCost
  ContractCost,

  ///ContractType
  ContractType,

  ///Contract_Item
  Contract_Item,

  ///Contract_Supplier
  Contract_Supplier,

  ///CronTask
  CronTask,

  ///CronTaskLog
  CronTaskLog,

  ///DBConnection
  DBConnection,

  ///DCRoom
  DCRoom,

  ///Datacenter
  Datacenter,

  ///DeviceBattery
  DeviceBattery,

  ///DeviceBatteryModel
  DeviceBatteryModel,

  ///DeviceBatteryType
  DeviceBatteryType,

  ///DeviceCase
  DeviceCase,

  ///DeviceCaseModel
  DeviceCaseModel,

  ///DeviceCaseType
  DeviceCaseType,

  ///DeviceControl
  DeviceControl,

  ///DeviceControlModel
  DeviceControlModel,

  ///DeviceDrive
  DeviceDrive,

  ///DeviceDriveModel
  DeviceDriveModel,

  ///DeviceFirmware
  DeviceFirmware,

  ///DeviceFirmwareModel
  DeviceFirmwareModel,

  ///DeviceFirmwareType
  DeviceFirmwareType,

  ///DeviceGeneric
  DeviceGeneric,

  ///DeviceGenericModel
  DeviceGenericModel,

  ///DeviceGenericType
  DeviceGenericType,

  ///DeviceGraphicCard
  DeviceGraphicCard,

  ///DeviceGraphicCardModel
  DeviceGraphicCardModel,

  ///DeviceHardDrive
  DeviceHardDrive,

  ///DeviceHardDriveModel
  DeviceHardDriveModel,

  ///DeviceMemory
  DeviceMemory,

  ///DeviceMemoryModel
  DeviceMemoryModel,

  ///DeviceMemoryType
  DeviceMemoryType,

  ///DeviceMotherBoardModel
  DeviceMotherBoardModel,

  ///DeviceMotherboard
  DeviceMotherboard,

  ///DeviceNetworkCard
  DeviceNetworkCard,

  ///DeviceNetworkCardModel
  DeviceNetworkCardModel,

  ///DevicePci
  DevicePci,

  ///DevicePciModel
  DevicePciModel,

  ///DevicePowerSupply
  DevicePowerSupply,

  ///DevicePowerSupplyModel
  DevicePowerSupplyModel,

  ///DeviceProcessor
  DeviceProcessor,

  ///DeviceProcessorModel
  DeviceProcessorModel,

  ///DeviceSensor
  DeviceSensor,

  ///DeviceSensorModel
  DeviceSensorModel,

  ///DeviceSensorType
  DeviceSensorType,

  ///DeviceSimcard
  DeviceSimcard,

  ///DeviceSimcardType
  DeviceSimcardType,

  ///DeviceSoundCard
  DeviceSoundCard,

  ///DeviceSoundCardModel
  DeviceSoundCardModel,

  ///DisplayPreference
  DisplayPreference,

  ///Document
  Document,

  ///DocumentCategory
  DocumentCategory,

  ///DocumentType
  DocumentType,

  ///Document_Item
  Document_Item,

  ///Domain
  Domain,

  ///DropdownTranslation
  DropdownTranslation,

  ///Enclosure
  Enclosure,

  ///EnclosureModel
  EnclosureModel,

  ///Entity
  Entity,

  ///Entity_KnowbaseItem
  Entity_KnowbaseItem,

  ///Entity_RSSFeed
  Entity_RSSFeed,

  ///Entity_Reminder
  Entity_Reminder,

  ///FQDN
  FQDN,

  ///FQDNLabel
  FQDNLabel,

  ///FieldUnicity
  FieldUnicity,

  ///Fieldblacklist
  Fieldblacklist,

  ///Filesystem
  Filesystem,

  ///Event
  Event,

  ///Group
  Group,

  ///Group_KnowbaseItem
  Group_KnowbaseItem,

  ///Group_Problem
  Group_Problem,

  ///Group_RSSFeed
  Group_RSSFeed,

  ///Group_Reminder
  Group_Reminder,

  ///Group_Ticket
  Group_Ticket,

  ///Group_User
  Group_User,

  ///Holiday
  Holiday,

  ///IPAddress
  IPAddress,

  ///IPAddress_IPNetwork
  IPAddress_IPNetwork,

  ///IPNetmask
  IPNetmask,

  ///IPNetwork
  IPNetwork,

  ///IPNetwork_Vlan
  IPNetwork_Vlan,

  ///ITILCategory
  ITILCategory,

  ///ITILFollowup
  ITILFollowup,

  ///ITILSolution
  ITILSolution,

  ///Infocom
  Infocom,

  ///InterfaceType
  InterfaceType,

  ///Item_DeviceBattery
  Item_DeviceBattery,

  ///Item_DeviceCase
  Item_DeviceCase,

  ///Item_DeviceControl
  Item_DeviceControl,

  ///Item_DeviceDrive
  Item_DeviceDrive,

  ///Item_DeviceFirmware
  Item_DeviceFirmware,

  ///Item_DeviceGeneric
  Item_DeviceGeneric,

  ///Item_DeviceGraphicCard
  Item_DeviceGraphicCard,

  ///Item_DeviceHardDrive
  Item_DeviceHardDrive,

  ///Item_DeviceMemory
  Item_DeviceMemory,

  ///Item_DeviceMotherboard
  Item_DeviceMotherboard,

  ///Item_DeviceNetworkCard
  Item_DeviceNetworkCard,

  ///Item_DevicePci
  Item_DevicePci,

  ///Item_DevicePowerSupply
  Item_DevicePowerSupply,

  ///Item_DeviceProcessor
  Item_DeviceProcessor,

  ///Item_DeviceSensor
  Item_DeviceSensor,

  ///Item_DeviceSimcard
  Item_DeviceSimcard,

  ///Item_DeviceSoundCard
  Item_DeviceSoundCard,

  ///Item_Devices
  Item_Devices,

  ///Item_Disk
  Item_Disk,

  ///Item_Enclosure
  Item_Enclosure,

  ///Item_OperatingSystem
  Item_OperatingSystem,

  ///Item_Problem
  Item_Problem,

  ///Item_Project
  Item_Project,

  ///Item_Rack
  Item_Rack,

  ///Item_Ticket
  Item_Ticket,

  ///Itil_Project
  Itil_Project,

  ///KnowbaseItem
  KnowbaseItem,

  ///KnowbaseItemCategory
  KnowbaseItemCategory,

  ///KnowbaseItemTranslation
  KnowbaseItemTranslation,

  ///KnowbaseItem_Comment
  KnowbaseItem_Comment,

  ///KnowbaseItem_Item
  KnowbaseItem_Item,

  ///KnowbaseItem_Profile
  KnowbaseItem_Profile,

  ///KnowbaseItem_Revision
  KnowbaseItem_Revision,

  ///KnowbaseItem_User
  KnowbaseItem_User,

  ///LevelAgreement
  LevelAgreement,

  ///LevelAgreementLevel
  LevelAgreementLevel,

  ///Line
  Line,

  ///LineOperator
  LineOperator,

  ///LineType
  LineType,

  ///Link
  Link,

  ///Link_Itemtype
  Link_Itemtype,

  ///Location
  Location,

  ///Log
  Log,

  ///MailCollector
  MailCollector,

  ///Manufacturer
  Manufacturer,

  ///Monitor
  Monitor,

  ///MonitorModel
  MonitorModel,

  ///MonitorType
  MonitorType,

  ///Netpoint
  Netpoint,

  ///Network
  Network,

  ///NetworkAlias
  NetworkAlias,

  ///NetworkEquipment
  NetworkEquipment,

  ///NetworkEquipmentModel
  NetworkEquipmentModel,

  ///NetworkEquipmentType
  NetworkEquipmentType,

  ///NetworkInterface
  NetworkInterface,

  ///NetworkName
  NetworkName,

  ///NetworkPort
  NetworkPort,

  ///NetworkPortAggregate
  NetworkPortAggregate,

  ///NetworkPortAlias
  NetworkPortAlias,

  ///NetworkPortDialup
  NetworkPortDialup,

  ///NetworkPortEthernet
  NetworkPortEthernet,

  ///NetworkPortFiberchannel
  NetworkPortFiberchannel,

  ///NetworkPortInstantiation
  NetworkPortInstantiation,

  ///NetworkPortLocal
  NetworkPortLocal,

  ///NetworkPortMigration
  NetworkPortMigration,

  ///NetworkPortWifi
  NetworkPortWifi,

  ///NetworkPort_NetworkPort
  NetworkPort_NetworkPort,

  ///NetworkPort_Vlan
  NetworkPort_Vlan,

  ///NotImportedEmail
  NotImportedEmail,

  ///Notepad
  Notepad,

  ///Notification
  Notification,

  ///NotificationAjaxSetting
  NotificationAjaxSetting,

  ///NotificationEvent
  NotificationEvent,

  ///NotificationMailingSetting
  NotificationMailingSetting,

  ///NotificationSetting
  NotificationSetting,

  ///NotificationSettingConfig
  NotificationSettingConfig,

  ///NotificationTarget
  NotificationTarget,

  ///NotificationTargetCartridgeItem
  NotificationTargetCartridgeItem,

  ///NotificationTargetCertificate
  NotificationTargetCertificate,

  ///NotificationTargetChange
  NotificationTargetChange,

  ///NotificationTargetCommonITILObject
  NotificationTargetCommonITILObject,

  ///NotificationTargetConsumableItem
  NotificationTargetConsumableItem,

  ///NotificationTargetContract
  NotificationTargetContract,

  ///NotificationTargetCrontask
  NotificationTargetCrontask,

  ///NotificationTargetDBConnection
  NotificationTargetDBConnection,

  ///NotificationTargetFieldUnicity
  NotificationTargetFieldUnicity,

  ///NotificationTargetInfocom
  NotificationTargetInfocom,

  ///NotificationTargetMailCollector
  NotificationTargetMailCollector,

  ///NotificationTargetObjectLock
  NotificationTargetObjectLock,

  ///NotificationTargetPlanningRecall
  NotificationTargetPlanningRecall,

  ///NotificationTargetProblem
  NotificationTargetProblem,

  ///NotificationTargetProject
  NotificationTargetProject,

  ///NotificationTargetProjectTask
  NotificationTargetProjectTask,

  ///NotificationTargetReservation
  NotificationTargetReservation,

  ///NotificationTargetSavedsearch_Alert
  NotificationTargetSavedsearch_Alert,

  ///NotificationTargetSoftwareLicense
  NotificationTargetSoftwareLicense,

  ///NotificationTargetTicket
  NotificationTargetTicket,

  ///NotificationTargetUser
  NotificationTargetUser,

  ///NotificationTemplate
  NotificationTemplate,

  ///NotificationTemplateTranslation
  NotificationTemplateTranslation,

  ///Notification_NotificationTemplate
  Notification_NotificationTemplate,

  ///OLA
  OLA,

  ///ObjectLock
  ObjectLock,

  ///OlaLevel
  OlaLevel,

  ///OlaLevelAction
  OlaLevelAction,

  ///OlaLevelCriteria
  OlaLevelCriteria,

  ///OlaLevel_Ticket
  OlaLevel_Ticket,

  ///OperatingSystem
  OperatingSystem,

  ///OperatingSystemArchitecture
  OperatingSystemArchitecture,

  ///OperatingSystemEdition
  OperatingSystemEdition,

  ///OperatingSystemKernel
  OperatingSystemKernel,

  ///OperatingSystemKernelVersion
  OperatingSystemKernelVersion,

  ///OperatingSystemServicePack
  OperatingSystemServicePack,

  ///OperatingSystemVersion
  OperatingSystemVersion,

  ///PDU
  PDU,

  ///PDUModel
  PDUModel,

  ///PDUType
  PDUType,

  ///PDU_Rack
  PDU_Rack,

  ///Pdu_Plug
  Pdu_Plug,

  ///Peripheral
  Peripheral,

  ///PeripheralModel
  PeripheralModel,

  ///PeripheralType
  PeripheralType,

  ///Phone
  Phone,

  ///PhoneModel
  PhoneModel,

  ///PhonePowerSupply
  PhonePowerSupply,

  ///PhoneType
  PhoneType,

  ///PlanningRecall
  PlanningRecall,

  ///Plug
  Plug,

  ///Plugin
  Plugin,

  ///Printer
  Printer,

  ///PrinterModel
  PrinterModel,

  ///PrinterType
  PrinterType,

  ///Problem
  Problem,

  ///ProblemCost
  ProblemCost,

  ///ProblemTask
  ProblemTask,

  ///Problem_Supplier
  Problem_Supplier,

  ///Problem_Ticket
  Problem_Ticket,

  ///Problem_User
  Problem_User,

  ///Profile
  Profile,

  ///ProfileRight
  ProfileRight,

  ///Profile_RSSFeed
  Profile_RSSFeed,

  ///Profile_Reminder
  Profile_Reminder,

  ///Profile_User
  Profile_User,

  ///Project
  Project,

  ///ProjectCost
  ProjectCost,

  ///ProjectState
  ProjectState,

  ///ProjectTask
  ProjectTask,

  ///ProjectTaskTeam
  ProjectTaskTeam,

  ///ProjectTaskTemplate
  ProjectTaskTemplate,

  ///ProjectTaskType
  ProjectTaskType,

  ///ProjectTask_Ticket
  ProjectTask_Ticket,

  ///ProjectTeam
  ProjectTeam,

  ///ProjectType
  ProjectType,

  ///PurgeLogs
  PurgeLogs,

  ///QueuedNotification
  QueuedNotification,

  ///RSSFeed
  RSSFeed,

  ///RSSFeed_User
  RSSFeed_User,

  ///Rack
  Rack,

  ///RackModel
  RackModel,

  ///RackType
  RackType,

  ///RegisteredID
  RegisteredID,

  ///Reminder
  Reminder,

  ///Reminder_User
  Reminder_User,

  ///RequestType
  RequestType,

  ///Reservation
  Reservation,

  ///ReservationItem
  ReservationItem,

  ///Rule
  Rule,

  ///RuleAction
  RuleAction,

  ///RuleAsset
  RuleAsset,

  ///RuleAssetCollection
  RuleAssetCollection,

  ///RuleCollection
  RuleCollection,

  ///RuleCriteria
  RuleCriteria,

  ///RuleDictionnaryComputerModel
  RuleDictionnaryComputerModel,

  ///RuleDictionnaryComputerModelCollection
  RuleDictionnaryComputerModelCollection,

  ///RuleDictionnaryComputerType
  RuleDictionnaryComputerType,

  ///RuleDictionnaryComputerTypeCollection
  RuleDictionnaryComputerTypeCollection,

  ///RuleDictionnaryDropdown
  RuleDictionnaryDropdown,

  ///RuleDictionnaryDropdownCollection
  RuleDictionnaryDropdownCollection,

  ///RuleDictionnaryManufacturer
  RuleDictionnaryManufacturer,

  ///RuleDictionnaryManufacturerCollection
  RuleDictionnaryManufacturerCollection,

  ///RuleDictionnaryMonitorModel
  RuleDictionnaryMonitorModel,

  ///RuleDictionnaryMonitorModelCollection
  RuleDictionnaryMonitorModelCollection,

  ///RuleDictionnaryMonitorType
  RuleDictionnaryMonitorType,

  ///RuleDictionnaryMonitorTypeCollection
  RuleDictionnaryMonitorTypeCollection,

  ///RuleDictionnaryNetworkEquipmentModel
  RuleDictionnaryNetworkEquipmentModel,

  ///RuleDictionnaryNetworkEquipmentModelCollection
  RuleDictionnaryNetworkEquipmentModelCollection,

  ///RuleDictionnaryNetworkEquipmentType
  RuleDictionnaryNetworkEquipmentType,

  ///RuleDictionnaryNetworkEquipmentTypeCollection
  RuleDictionnaryNetworkEquipmentTypeCollection,

  ///RuleDictionnaryOperatingSystem
  RuleDictionnaryOperatingSystem,

  ///RuleDictionnaryOperatingSystemArchitecture
  RuleDictionnaryOperatingSystemArchitecture,

  ///RuleDictionnaryOperatingSystemArchitectureCollection
  RuleDictionnaryOperatingSystemArchitectureCollection,

  ///RuleDictionnaryOperatingSystemCollection
  RuleDictionnaryOperatingSystemCollection,

  ///RuleDictionnaryOperatingSystemServicePack
  RuleDictionnaryOperatingSystemServicePack,

  ///RuleDictionnaryOperatingSystemServicePackCollection
  RuleDictionnaryOperatingSystemServicePackCollection,

  ///RuleDictionnaryOperatingSystemVersion
  RuleDictionnaryOperatingSystemVersion,

  ///RuleDictionnaryOperatingSystemVersionCollection
  RuleDictionnaryOperatingSystemVersionCollection,

  ///RuleDictionnaryPeripheralModel
  RuleDictionnaryPeripheralModel,

  ///RuleDictionnaryPeripheralModelCollection
  RuleDictionnaryPeripheralModelCollection,

  ///RuleDictionnaryPeripheralType
  RuleDictionnaryPeripheralType,

  ///RuleDictionnaryPeripheralTypeCollection
  RuleDictionnaryPeripheralTypeCollection,

  ///RuleDictionnaryPhoneModel
  RuleDictionnaryPhoneModel,

  ///RuleDictionnaryPhoneModelCollection
  RuleDictionnaryPhoneModelCollection,

  ///RuleDictionnaryPhoneType
  RuleDictionnaryPhoneType,

  ///RuleDictionnaryPhoneTypeCollection
  RuleDictionnaryPhoneTypeCollection,

  ///RuleDictionnaryPrinter
  RuleDictionnaryPrinter,

  ///RuleDictionnaryPrinterCollection
  RuleDictionnaryPrinterCollection,

  ///RuleDictionnaryPrinterModel
  RuleDictionnaryPrinterModel,

  ///RuleDictionnaryPrinterModelCollection
  RuleDictionnaryPrinterModelCollection,

  ///RuleDictionnaryPrinterType
  RuleDictionnaryPrinterType,

  ///RuleDictionnaryPrinterTypeCollection
  RuleDictionnaryPrinterTypeCollection,

  ///RuleDictionnarySoftware
  RuleDictionnarySoftware,

  ///RuleDictionnarySoftwareCollection
  RuleDictionnarySoftwareCollection,

  ///RuleImportComputer
  RuleImportComputer,

  ///RuleImportComputerCollection
  RuleImportComputerCollection,

  ///RuleImportEntity
  RuleImportEntity,

  ///RuleImportEntityCollection
  RuleImportEntityCollection,

  ///RuleMailCollector
  RuleMailCollector,

  ///RuleMailCollectorCollection
  RuleMailCollectorCollection,

  ///RuleRight
  RuleRight,

  ///RuleRightCollection
  RuleRightCollection,

  ///RuleRightParameter
  RuleRightParameter,

  ///RuleSoftwareCategory
  RuleSoftwareCategory,

  ///RuleSoftwareCategoryCollection
  RuleSoftwareCategoryCollection,

  ///RuleTicket
  RuleTicket,

  ///RuleTicketCollection
  RuleTicketCollection,

  ///SLA
  SLA,

  ///SLM
  SLM,

  ///SavedSearch
  SavedSearch,

  ///SavedSearch_Alert
  SavedSearch_Alert,

  ///SavedSearch_User
  SavedSearch_User,

  ///SlaLevel
  SlaLevel,

  ///SlaLevelAction
  SlaLevelAction,

  ///SlaLevelCriteria
  SlaLevelCriteria,

  ///SlaLevel_Ticket
  SlaLevel_Ticket,

  ///Software
  Software,

  ///SoftwareCategory
  SoftwareCategory,

  ///SoftwareLicense
  SoftwareLicense,

  ///SoftwareLicenseType
  SoftwareLicenseType,

  ///SoftwareVersion
  SoftwareVersion,

  ///SolutionTemplate
  SolutionTemplate,

  ///SolutionType
  SolutionType,

  ///SsoVariable
  SsoVariable,

  ///State
  State,

  ///Supplier
  Supplier,

  ///SupplierType
  SupplierType,

  ///Supplier_Ticket
  Supplier_Ticket,

  ///TaskCategory
  TaskCategory,

  ///TaskTemplate
  TaskTemplate,

  ///Ticket
  Ticket,

  ///TicketCost
  TicketCost,

  ///TicketFollowup
  TicketFollowup,

  ///TicketRecurrent
  TicketRecurrent,

  ///TicketSatisfaction
  TicketSatisfaction,

  ///TicketTask
  TicketTask,

  ///TicketTemplate
  TicketTemplate,

  ///TicketTemplateHiddenField
  TicketTemplateHiddenField,

  ///TicketTemplateMandatoryField
  TicketTemplateMandatoryField,

  ///TicketTemplatePredefinedField
  TicketTemplatePredefinedField,

  ///TicketValidation
  TicketValidation,

  ///Ticket_Ticket
  Ticket_Ticket,

  ///Ticket_User
  Ticket_User,

  ///Transfer
  Transfer,

  ///User
  User,

  ///UserCategory
  UserCategory,

  ///UserEmail
  UserEmail,

  ///UserTitle
  UserTitle,

  ///VirtualMachineState
  VirtualMachineState,

  ///VirtualMachineSystem
  VirtualMachineSystem,

  ///VirtualMachineType
  VirtualMachineType,

  ///Vlan
  Vlan,

  ///WifiNetwork
  WifiNetwork,
}
