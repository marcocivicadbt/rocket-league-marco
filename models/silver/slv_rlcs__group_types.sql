select
    group_type_id,
    group_type_name
from {{ ref('group_types') }}