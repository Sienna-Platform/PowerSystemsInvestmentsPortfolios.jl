using Documenter, PowerSystemsInvestmentsPortfolios
import DataStructures: OrderedDict

include(joinpath(@__DIR__, "make_model_library.jl"))
include(joinpath(@__DIR__, "make_tutorials.jl"))

pages = OrderedDict(
    "Welcome Page" => "index.md",
    "Quick Start Guide" => "quick_start_guide.md",
    "Tutorials" => Any[],   # populated below by make_tutorials()
    "How to..." => Any[
        "...define regions and topology" => "how_to/define_topology.md",
        "...add technologies" => Any[
            "Add a Supply Technology" => "how_to/add_supply_technology.md",
            "Add a Storage Technology" => "how_to/add_storage_technology.md",
            "Add a Co-located Supply and Storage Technology" => "how_to/add_colocated_technology.md",
            "Add a Transmission Technology" => "how_to/add_transmission_technology.md",
            "Add a Demand Technology" => "how_to/add_demand_technology.md",
        ],
        "...link existing, retiring, and retrofit capacity" => "how_to/add_existing_capacity.md",
        "...add requirements" => "how_to/add_requirements.md",
        "...configure financial data" => "how_to/configure_financial_data.md",
        "...work with units" => "how_to/work_with_units.md",
        "...save and load a Portfolio" => "how_to/serialize_portfolio.md",
        "...update to a new version" => Any["Migrate to the PowerSystems 6 data model" => "how_to/migrate_to_psy6.md",],
    ],
    "Explanation" => Any[
        "The Portfolio Container" => "explanation/portfolio.md",
        "Technology Types" => "explanation/technology_types.md",
        "Investment and Operational Time Periods" => "explanation/investment_time_periods.md",
        "Regions and Topology" => "explanation/regions_and_topology.md",
        "Requirements and Policy Constraints" => "explanation/requirements.md",
        "Financial Data" => "explanation/financial_data.md",
        "Units and Unit Conversions" => "explanation/units_and_conversions.md",
        "Database Integration" => "explanation/database_integration.md",
        "The Sienna Stack" => "explanation/sienna_stack.md",
    ],
    "Model Library" => Any[],   # populated below by make_model_library()
    "Reference" => Any[
        "Public API Reference" => "api/public.md",
        "Glossary" => "api/glossary.md",
        "Type Tree" => "api/type_tree.md",
        "Citation" => "api/citation.md",
        "Developers" => Any[
            "Developer Guidelines" => "api/developer_guidelines.md",
            "Internals" => "api/internal.md",
        ],
    ],
)

pages["Tutorials"] = make_tutorials()

pages["Model Library"] = make_model_library(
    # Parametric technology types have no concrete subtypes, so only Requirement generates
    # pages; the technologies are documented on the manual pages below.
    categories=[ResourceTechnology, DemandTechnology, TransmissionTechnology, Requirement],
    manual_additions=Dict{String, Any}(
        "ResourceTechnology" => Any[
            "Supply Technology" => "model_library/supply_technology.md",
            "Storage Technology" => "model_library/storage_technology.md",
        ],
        "TransmissionTechnology" =>
            Any["Transport Technologies" => "model_library/transport_technologies.md",],
        "DemandTechnology" =>
            Any["Demand Technologies" => "model_library/demand_technologies.md",],
        "Requirement" =>
            Any["Policy Requirements" => "model_library/requirements_models.md",],
        "Supplemental Attributes" =>
            Any["Existing, Retirement, and Retrofit Data" => "model_library/supplemental_attributes.md",],
        "Costs and Financial Data" =>
            Any["Capital Costs and Financial Data" => "model_library/costs_and_financial_data.md",],
    ),
)

makedocs(
    modules=[PowerSystemsInvestmentsPortfolios],
    format=Documenter.HTML(
        prettyurls=haskey(ENV, "GITHUB_ACTIONS"),
        size_threshold=nothing,
    ),
    sitename="PowerSystemsInvestmentsPortfolios.jl",
    authors="Jose Daniel Lara, Rodrigo Henriquez-Auba, and Contributors",
    pages=Any[p for p in pages],
    draft=false,
    warnonly=true,
)

deploydocs(
    repo="github.com/Sienna-Platform/PowerSystemsInvestmentsPortfolios.git",
    target="build",
    branch="gh-pages",
    devbranch="main",
    devurl="dev",
    push_preview=true,
    versions=["stable" => "v^", "v#.#"],
)
